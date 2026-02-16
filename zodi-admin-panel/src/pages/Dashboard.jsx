import { useState, useEffect } from 'react'
import {
  Users, Activity, Crown, UserPlus, LogIn,
  Sparkles, RefreshCw, ArrowUpRight, Clock
} from 'lucide-react'
import { db } from '../firebase'
import {
  collection, query, where, getDocs, limit,
  Timestamp, onSnapshot, orderBy
} from 'firebase/firestore'

// ─── Helpers ───────────────────────────────────────────────

const toDate = (ts) => {
  if (!ts) return null
  try {
    if (ts.toDate) return ts.toDate()
    if (ts.seconds) return new Date(ts.seconds * 1000)
    if (ts instanceof Date) return ts
    const d = new Date(ts)
    return isNaN(d.getTime()) ? null : d
  } catch { return null }
}

const timeAgo = (date) => {
  if (!date) return ''
  const s = Math.floor((Date.now() - date) / 1000)
  if (s < 0) return 'Az önce'
  if (s < 60) return `${s}sn önce`
  const m = Math.floor(s / 60)
  if (m < 60) return `${m}dk önce`
  const h = Math.floor(m / 60)
  if (h < 24) return `${h}sa önce`
  const d = Math.floor(h / 24)
  return `${d}g önce`
}

// Aktivite tipi → emoji, renk, label
const activityMeta = {
  signup:               { icon: '🎉', bg: 'from-emerald-400 to-green-500',  label: 'Yeni Kayıt' },
  login:                { icon: '🔓', bg: 'from-blue-400 to-blue-500',      label: 'Giriş' },
  app_open:             { icon: '📱', bg: 'from-gray-400 to-gray-500',      label: 'Uygulama Açıldı' },
  daily_horoscope:      { icon: '🔮', bg: 'from-violet-400 to-purple-500',  label: 'Günlük Yorum' },
  tarot_reading:        { icon: '🃏', bg: 'from-fuchsia-400 to-pink-500',   label: 'Tarot' },
  dream_interpretation: { icon: '🌙', bg: 'from-indigo-400 to-blue-500',    label: 'Rüya Yorumu' },
  rising_sign:          { icon: '⬆️', bg: 'from-teal-400 to-cyan-500',      label: 'Yükselen Burç' },
  compatibility:        { icon: '💕', bg: 'from-pink-400 to-rose-500',      label: 'Uyumluluk' },
  weekly_horoscope:     { icon: '📅', bg: 'from-sky-400 to-blue-500',       label: 'Haftalık' },
  monthly_horoscope:    { icon: '📊', bg: 'from-cyan-400 to-teal-500',      label: 'Aylık' },
  birth_chart:          { icon: '🪐', bg: 'from-amber-400 to-orange-500',   label: 'Doğum Haritası' },
  premium_purchase:     { icon: '💎', bg: 'from-yellow-400 to-amber-500',   label: 'Premium' },
  ad_watched:           { icon: '📺', bg: 'from-gray-400 to-slate-500',     label: 'Reklam' },
}

const fallbackMeta = { icon: '❓', bg: 'from-gray-400 to-gray-500', label: 'Bilinmeyen' }

// ─── Dashboard Component ───────────────────────────────────

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    todaySignups: 0,
    todayLogins: 0,
    premiumUsers: 0,
    todayActivities: 0,
  })
  const [loading, setLoading] = useState(true)
  const [feed, setFeed] = useState([])
  const [livePulse, setLivePulse] = useState(null)

  useEffect(() => {
    loadAll()
    const unsub = startLiveListener()
    const iv = setInterval(() => loadRecentFeed(), 20000)
    return () => { unsub(); clearInterval(iv) }
  }, [])

  const loadAll = async () => {
    setLoading(true)
    await Promise.all([loadStats(), loadRecentFeed()])
    setLoading(false)
  }

  // ─── Stats ────────────────────────────────────────────

  const loadStats = async () => {
    try {
      const usersSnap = await getDocs(collection(db, 'users'))
      const totalUsers = usersSnap.size
      const premiumUsers = usersSnap.docs.filter(d => d.data().isPremium).length

      const todayStart = new Date()
      todayStart.setHours(0, 0, 0, 0)

      let logsSnap
      try {
        logsSnap = await getDocs(
          query(
            collection(db, 'activity_logs'),
            where('timestamp', '>=', Timestamp.fromDate(todayStart)),
            orderBy('timestamp', 'desc'),
            limit(500)
          )
        )
      } catch {
        // Index yoksa tüm logları çek ve client-side filtrele
        logsSnap = await getDocs(
          query(collection(db, 'activity_logs'), orderBy('timestamp', 'desc'), limit(500))
        )
      }

      let todaySignups = 0
      let todayLogins = 0
      let todayActivities = 0

      logsSnap.docs.forEach(d => {
        const data = d.data()
        const ts = toDate(data.timestamp)
        const isToday = ts && ts >= todayStart

        if (isToday) {
          todayActivities++
          if (data.type === 'signup') todaySignups++
          if (data.type === 'login') todayLogins++
        }
      })

      setStats({ totalUsers, todaySignups, todayLogins, premiumUsers, todayActivities })
    } catch (e) {
      console.error('Stats hata:', e)
    }
  }

  // ─── Recent feed ──────────────────────────────────────

  const loadRecentFeed = async () => {
    try {
      const snap = await getDocs(
        query(collection(db, 'activity_logs'), orderBy('timestamp', 'desc'), limit(30))
      )

      setFeed(snap.docs.map(d => {
        const data = d.data()
        return {
          id: d.id,
          ...data,
          date: toDate(data.timestamp),
          meta: activityMeta[data.type] || fallbackMeta,
        }
      }))
    } catch (e) {
      console.error('Feed hata:', e)
    }
  }

  // ─── Realtime listener ────────────────────────────────

  const startLiveListener = () => {
    let first = true
    return onSnapshot(
      query(collection(db, 'activity_logs'), orderBy('timestamp', 'desc'), limit(1)),
      (snap) => {
        if (first) { first = false; return }
        snap.docChanges().forEach(ch => {
          if (ch.type === 'added') {
            const data = ch.doc.data()
            const ts = toDate(data.timestamp)
            if (ts && (Date.now() - ts) < 15000) {
              const meta = activityMeta[data.type] || fallbackMeta
              setLivePulse({
                user: data.userName || 'Kullanıcı',
                action: data.action || meta.label,
                meta,
              })
              loadRecentFeed()
              loadStats()
              setTimeout(() => setLivePulse(null), 6000)
            }
          }
        })
      }
    )
  }

  // ─── Render ───────────────────────────────────────────

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto" />
          <p className="mt-4 text-gray-500">Veriler yükleniyor...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
            Dashboard
          </h1>
          <p className="text-gray-500 mt-1">Zodi — Gerçek zamanlı genel bakış</p>
        </div>
        <button
          onClick={loadAll}
          className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition text-sm font-medium text-gray-700"
        >
          <RefreshCw className="w-4 h-4" />
          Yenile
        </button>
      </div>

      {/* Live Pulse Banner */}
      {livePulse && (
        <div className="bg-gradient-to-r from-purple-500 via-fuchsia-500 to-pink-500 rounded-2xl p-4 text-white shadow-lg shadow-purple-200 animate-pulse">
          <div className="flex items-center gap-4">
            <div className="text-3xl animate-bounce">{livePulse.meta.icon}</div>
            <div className="flex-1">
              <div className="flex items-center gap-2 text-sm font-medium text-white/80">
                <Sparkles className="w-4 h-4 animate-pulse" />
                Canlı Aktivite
              </div>
              <p className="font-semibold mt-0.5">
                {livePulse.user} — {livePulse.action}
              </p>
            </div>
            <span className="text-xs bg-white/20 px-3 py-1 rounded-full">Şimdi</span>
          </div>
        </div>
      )}

      {/* Stat Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-5 gap-4">
        <StatBox label="Toplam Kullanıcı" value={stats.totalUsers} icon={<Users className="w-6 h-6" />} gradient="from-blue-500 to-blue-600" />
        <StatBox label="Bugün Kayıt" value={stats.todaySignups} icon={<UserPlus className="w-6 h-6" />} gradient="from-emerald-500 to-green-600" />
        <StatBox label="Bugün Giriş" value={stats.todayLogins} icon={<LogIn className="w-6 h-6" />} gradient="from-sky-500 to-blue-600" />
        <StatBox label="Premium Üye" value={stats.premiumUsers} icon={<Crown className="w-6 h-6" />} gradient="from-amber-500 to-orange-500" />
        <StatBox label="Bugün Aktivite" value={stats.todayActivities} icon={<Activity className="w-6 h-6" />} gradient="from-purple-500 to-fuchsia-600" />
      </div>

      {/* Activity Feed */}
      <div className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden">
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100">
          <div className="flex items-center gap-2">
            <Activity className="w-5 h-5 text-purple-600" />
            <h2 className="text-lg font-semibold text-gray-900">Son Aktiviteler</h2>
          </div>
          <div className="flex items-center gap-2 text-xs text-gray-400">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
            Canlı
          </div>
        </div>

        {feed.length === 0 ? (
          <div className="text-center py-16">
            <Activity className="w-12 h-12 text-gray-200 mx-auto mb-3" />
            <p className="text-gray-400">Henüz aktivite yok</p>
            <p className="text-sm text-gray-300 mt-1">Kullanıcılar uygulamayı kullandıkça burada görünecek</p>
          </div>
        ) : (
          <div className="divide-y divide-gray-50">
            {feed.map((item) => (
              <div key={item.id} className="flex items-center gap-4 px-6 py-3.5 hover:bg-gray-50/50 transition">
                {/* Icon */}
                <div className={`w-10 h-10 rounded-xl bg-gradient-to-br ${item.meta.bg} flex items-center justify-center text-lg shadow-sm shrink-0`}>
                  {item.meta.icon}
                </div>

                {/* Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-sm text-gray-900 truncate">
                      {item.userName || 'Anonim'}
                    </span>
                    {item.zodiacSign && (
                      <span className="text-xs bg-purple-50 text-purple-600 px-1.5 py-0.5 rounded font-medium">
                        {item.zodiacSign}
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-gray-500 truncate">
                    {item.action || item.meta.label}
                    {item.metadata?.cardName && (
                      <span className="ml-1 text-xs text-purple-500">• {item.metadata.cardName}</span>
                    )}
                    {item.metadata?.sign1 && item.metadata?.sign2 && (
                      <span className="ml-1 text-xs text-pink-500">• {item.metadata.sign1} ↔ {item.metadata.sign2}</span>
                    )}
                    {item.metadata?.risingSign && (
                      <span className="ml-1 text-xs text-teal-500">• {item.metadata.risingSign}</span>
                    )}
                    {item.metadata?.price && (
                      <span className="ml-1 text-xs text-amber-500">• ₺{item.metadata.price}</span>
                    )}
                  </p>
                </div>

                {/* Type badge */}
                <span className={`hidden sm:inline-flex text-xs font-medium px-2 py-1 rounded-lg bg-gradient-to-r ${item.meta.bg} text-white`}>
                  {item.meta.label}
                </span>

                {/* Time */}
                <div className="flex items-center gap-1 text-xs text-gray-400 shrink-0">
                  <Clock className="w-3 h-3" />
                  {item.date ? timeAgo(item.date) : '—'}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Activity Type Breakdown */}
      <ActivityBreakdown feed={feed} />
    </div>
  )
}

// ─── Sub-Components ─────────────────────────────────────────

function StatBox({ label, value, icon, gradient }) {
  return (
    <div className={`bg-gradient-to-br ${gradient} rounded-2xl p-5 text-white shadow-sm hover:shadow-lg transition-shadow`}>
      <div className="flex items-center justify-between mb-3">
        <div className="p-2 bg-white/20 rounded-lg">{icon}</div>
        <ArrowUpRight className="w-4 h-4 text-white/60" />
      </div>
      <p className="text-3xl font-bold">{value.toLocaleString()}</p>
      <p className="text-sm text-white/80 mt-1">{label}</p>
    </div>
  )
}

function ActivityBreakdown({ feed }) {
  const counts = {}
  feed.forEach(item => {
    const t = item.type || 'unknown'
    counts[t] = (counts[t] || 0) + 1
  })

  const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1])
  if (sorted.length === 0) return null

  const max = sorted[0][1]

  return (
    <div className="bg-white rounded-2xl border border-gray-200 shadow-sm p-6">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Aktivite Dağılımı</h3>
      <div className="space-y-3">
        {sorted.map(([type, count]) => {
          const meta = activityMeta[type] || fallbackMeta
          const pct = Math.round((count / max) * 100)
          return (
            <div key={type} className="flex items-center gap-3">
              <span className="text-xl w-8 text-center">{meta.icon}</span>
              <span className="text-sm font-medium text-gray-700 w-32 truncate">{meta.label}</span>
              <div className="flex-1 bg-gray-100 rounded-full h-2.5 overflow-hidden">
                <div
                  className={`h-full rounded-full bg-gradient-to-r ${meta.bg}`}
                  style={{ width: `${pct}%` }}
                />
              </div>
              <span className="text-sm font-bold text-gray-800 w-8 text-right">{count}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
