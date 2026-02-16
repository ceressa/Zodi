import { useState, useEffect } from 'react'
import { Activity, Calendar, Clock, Filter, RefreshCw, Zap } from 'lucide-react'
import { db } from '../firebase'
import { collection, getDocs, query, orderBy, limit, onSnapshot } from 'firebase/firestore'
import { format } from 'date-fns'
import { tr } from 'date-fns/locale'

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
  if (!date) return 'Bilinmiyor'
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

const activityConfig = {
  signup:               { icon: '🎉', color: 'text-emerald-600', bgColor: 'bg-emerald-50', label: 'Yeni Kayıt' },
  login:                { icon: '🔓', color: 'text-blue-600',    bgColor: 'bg-blue-50',    label: 'Giriş' },
  app_open:             { icon: '📱', color: 'text-gray-600',    bgColor: 'bg-gray-50',    label: 'Uygulama Açıldı' },
  daily_horoscope:      { icon: '🔮', color: 'text-purple-600',  bgColor: 'bg-purple-50',  label: 'Günlük Yorum' },
  tarot_reading:        { icon: '🃏', color: 'text-fuchsia-600', bgColor: 'bg-fuchsia-50', label: 'Tarot' },
  dream_interpretation: { icon: '🌙', color: 'text-indigo-600',  bgColor: 'bg-indigo-50',  label: 'Rüya Yorumu' },
  rising_sign:          { icon: '⬆️', color: 'text-teal-600',    bgColor: 'bg-teal-50',    label: 'Yükselen Burç' },
  compatibility:        { icon: '💕', color: 'text-pink-600',    bgColor: 'bg-pink-50',    label: 'Uyumluluk' },
  weekly_horoscope:     { icon: '📅', color: 'text-sky-600',     bgColor: 'bg-sky-50',     label: 'Haftalık' },
  monthly_horoscope:    { icon: '📊', color: 'text-cyan-600',    bgColor: 'bg-cyan-50',    label: 'Aylık' },
  birth_chart:          { icon: '🪐', color: 'text-amber-600',   bgColor: 'bg-amber-50',   label: 'Doğum Haritası' },
  premium_purchase:     { icon: '💎', color: 'text-yellow-600',  bgColor: 'bg-yellow-50',  label: 'Premium' },
  ad_watched:           { icon: '📺', color: 'text-slate-600',   bgColor: 'bg-slate-50',   label: 'Reklam' },
}

const fallbackConfig = { icon: '❓', color: 'text-gray-600', bgColor: 'bg-gray-50', label: 'Bilinmeyen' }

export default function ActivityLogs() {
  const [logs, setLogs] = useState([])
  const [loading, setLoading] = useState(true)
  const [timeFilter, setTimeFilter] = useState('all')
  const [typeFilter, setTypeFilter] = useState('all')
  const [stats, setStats] = useState({ total: 0, today: 0, week: 0, types: 0 })

  useEffect(() => {
    loadLogs()
  }, [timeFilter, typeFilter])

  // Realtime listener for new entries
  useEffect(() => {
    let first = true
    const unsub = onSnapshot(
      query(collection(db, 'activity_logs'), orderBy('timestamp', 'desc'), limit(1)),
      () => {
        if (first) { first = false; return }
        loadLogs()
      }
    )
    return unsub
  }, [timeFilter, typeFilter])

  const loadLogs = async () => {
    setLoading(true)
    try {
      const snap = await getDocs(
        query(collection(db, 'activity_logs'), orderBy('timestamp', 'desc'), limit(500))
      )

      const today = new Date(); today.setHours(0, 0, 0, 0)
      const weekAgo = new Date(); weekAgo.setDate(weekAgo.getDate() - 7)
      const monthAgo = new Date(); monthAgo.setMonth(monthAgo.getMonth() - 1)

      let todayCount = 0, weekCount = 0
      const typesSet = new Set()
      const filtered = []

      snap.docs.forEach(doc => {
        const data = doc.data()
        const date = toDate(data.timestamp)
        if (!date) return

        typesSet.add(data.type)
        if (date >= today) todayCount++
        if (date >= weekAgo) weekCount++

        // Time filter
        if (timeFilter === 'today' && date < today) return
        if (timeFilter === 'week' && date < weekAgo) return
        if (timeFilter === 'month' && date < monthAgo) return

        // Type filter
        if (typeFilter !== 'all' && data.type !== typeFilter) return

        const config = activityConfig[data.type] || fallbackConfig
        filtered.push({
          id: doc.id,
          ...data,
          date,
          config,
        })
      })

      setStats({ total: snap.size, today: todayCount, week: weekCount, types: typesSet.size })
      setLogs(filtered)
    } catch (e) {
      console.error('Log yükleme hatası:', e)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl shadow-lg shadow-purple-200">
            <Zap className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Aktivite Logları</h1>
            <p className="text-sm text-gray-500">Tüm kullanıcı aktiviteleri — canlı güncelleniyor</p>
          </div>
        </div>
        <button
          onClick={loadLogs}
          className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition text-sm font-medium"
        >
          <RefreshCw className="w-4 h-4" />
          Yenile
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <MiniStat icon={<Activity className="w-5 h-5" />} label="Toplam" value={stats.total} gradient="from-blue-500 to-blue-600" />
        <MiniStat icon={<Calendar className="w-5 h-5" />} label="Bugün" value={stats.today} gradient="from-green-500 to-emerald-600" />
        <MiniStat icon={<Clock className="w-5 h-5" />} label="Son 7 Gün" value={stats.week} gradient="from-purple-500 to-fuchsia-600" />
        <MiniStat icon={<Zap className="w-5 h-5" />} label="Aktivite Tipi" value={stats.types} gradient="from-orange-500 to-amber-600" />
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl border border-gray-200 p-4 flex flex-wrap gap-4 items-center">
        <div className="flex items-center gap-2">
          <Filter className="w-4 h-4 text-gray-400" />
          <span className="text-sm font-medium text-gray-600">Zaman:</span>
          {['all', 'today', 'week', 'month'].map(f => (
            <button
              key={f}
              onClick={() => setTimeFilter(f)}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition ${
                timeFilter === f
                  ? 'bg-purple-500 text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {f === 'all' ? 'Tümü' : f === 'today' ? 'Bugün' : f === 'week' ? '7 Gün' : '30 Gün'}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-600">Tip:</span>
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="px-3 py-1.5 rounded-lg text-sm bg-gray-100 text-gray-700 border-none focus:ring-2 focus:ring-purple-500"
          >
            <option value="all">Tümü</option>
            {Object.entries(activityConfig).map(([key, cfg]) => (
              <option key={key} value={key}>{cfg.icon} {cfg.label}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl border border-gray-200 overflow-hidden shadow-sm">
        {loading ? (
          <div className="flex items-center justify-center py-16">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-500" />
          </div>
        ) : logs.length === 0 ? (
          <div className="text-center py-16">
            <Activity className="w-12 h-12 text-gray-200 mx-auto mb-3" />
            <p className="text-gray-400">Bu filtreyle eşleşen aktivite yok</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50/80 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Kullanıcı</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Aktivite</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Detay</th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Zaman</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {logs.map((log) => (
                  <tr key={log.id} className="hover:bg-gray-50/50 transition">
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center text-white text-sm font-bold shrink-0">
                          {(log.userName || '?')[0].toUpperCase()}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">{log.userName || 'Anonim'}</p>
                          {log.zodiacSign && (
                            <span className="text-xs text-purple-500">{log.zodiacSign}</span>
                          )}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-2">
                        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium ${log.config.bgColor} ${log.config.color}`}>
                          <span>{log.config.icon}</span>
                          {log.config.label}
                        </span>
                      </div>
                      <p className="text-xs text-gray-400 mt-0.5">{log.action}</p>
                    </td>
                    <td className="px-6 py-3.5">
                      <div className="flex flex-wrap gap-1">
                        {log.metadata?.cardName && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-purple-100 text-purple-700">{log.metadata.cardName}</span>
                        )}
                        {log.metadata?.sign1 && log.metadata?.sign2 && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-pink-100 text-pink-700">{log.metadata.sign1} ↔ {log.metadata.sign2}</span>
                        )}
                        {log.metadata?.risingSign && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-teal-100 text-teal-700">Yükselen: {log.metadata.risingSign}</span>
                        )}
                        {log.metadata?.price && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-amber-100 text-amber-700">₺{log.metadata.price}</span>
                        )}
                        {log.metadata?.zodiacSign && log.type !== 'signup' && log.type !== 'login' && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-violet-100 text-violet-700">{log.metadata.zodiacSign}</span>
                        )}
                        {log.metadata?.method && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-blue-100 text-blue-700">{log.metadata.method}</span>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <p className="text-sm text-gray-900">{format(log.date, 'dd MMM yyyy', { locale: tr })}</p>
                      <p className="text-xs text-gray-400">{format(log.date, 'HH:mm:ss')} • {timeAgo(log.date)}</p>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}

function MiniStat({ icon, label, value, gradient }) {
  return (
    <div className={`bg-gradient-to-br ${gradient} rounded-xl p-4 text-white`}>
      <div className="flex items-center justify-between mb-1">
        <div className="opacity-80">{icon}</div>
        <span className="text-2xl font-bold">{value}</span>
      </div>
      <p className="text-sm opacity-90">{label}</p>
    </div>
  )
}
