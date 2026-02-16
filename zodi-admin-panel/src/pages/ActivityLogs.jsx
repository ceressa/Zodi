import { useState, useEffect } from 'react'
import { Activity, User, Crown, Calendar, Clock, Filter, RefreshCw, Zap } from 'lucide-react'
import { db } from '../firebase'
import { collection, getDocs, query, orderBy, limit, where, Timestamp } from 'firebase/firestore'
import { format } from 'date-fns'
import { tr } from 'date-fns/locale'

// Helper function to safely convert Firestore timestamp to Date
const toDate = (timestamp) => {
  if (!timestamp) return null
  
  try {
    if (timestamp.toDate && typeof timestamp.toDate === 'function') {
      return timestamp.toDate()
    }
    if (timestamp.seconds) {
      return new Date(timestamp.seconds * 1000)
    }
    if (timestamp instanceof Date) {
      return timestamp
    }
    const parsed = new Date(timestamp)
    if (!isNaN(parsed.getTime())) {
      return parsed
    }
    return null
  } catch (e) {
    console.error('Timestamp parse hatası:', e, timestamp)
    return null
  }
}

const getTimeAgo = (date) => {
  if (!date || !(date instanceof Date) || isNaN(date.getTime())) {
    return 'Bilinmiyor'
  }
  
  const seconds = Math.floor((new Date() - date) / 1000)
  
  if (seconds < 0) return 'Az önce'
  if (seconds < 60) return `${seconds} saniye önce`
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes} dakika önce`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours} saat önce`
  const days = Math.floor(hours / 24)
  if (days < 30) return `${days} gün önce`
  const months = Math.floor(days / 30)
  if (months < 12) return `${months} ay önce`
  const years = Math.floor(months / 12)
  return `${years} yıl önce`
}

// Activity type icons and colors
const activityConfig = {
  daily_horoscope: { icon: '📅', color: 'text-blue-600', label: 'Günlük Yorum' },
  tarot_reading: { icon: '🔮', color: 'text-purple-600', label: 'Tarot' },
  dream_interpretation: { icon: '🌙', color: 'text-indigo-600', label: 'Rüya Yorumu' },
  rising_sign: { icon: '⬆️', color: 'text-green-600', label: 'Yükselen Burç' },
  compatibility: { icon: '💕', color: 'text-pink-600', label: 'Uyumluluk' },
  weekly_horoscope: { icon: '📆', color: 'text-cyan-600', label: 'Haftalık' },
  monthly_horoscope: { icon: '📊', color: 'text-teal-600', label: 'Aylık' },
  premium_purchase: { icon: '💎', color: 'text-yellow-600', label: 'Premium' },
  login: { icon: '🔓', color: 'text-gray-600', label: 'Giriş' },
  signup: { icon: '✨', color: 'text-emerald-600', label: 'Kayıt' },
}

export default function ActivityLogs() {
  const [logs, setLogs] = useState([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState('all') // all, today, week, month
  const [typeFilter, setTypeFilter] = useState('all') // all, daily_horoscope, tarot_reading, etc.
  const [stats, setStats] = useState({
    total: 0,
    today: 0,
    week: 0,
    byType: {}
  })

  useEffect(() => {
    loadActivityLogs()
  }, [filter, typeFilter])

  const loadActivityLogs = async () => {
    setLoading(true)
    try {
      console.log('🔍 Aktivite logları yükleniyor...')
      
      // activity_logs koleksiyonundan veri çek
      let q = query(
        collection(db, 'activity_logs'),
        orderBy('timestamp', 'desc'),
        limit(500)
      )
      
      const logsSnapshot = await getDocs(q)
      
      console.log('📊 Toplam aktivite sayısı:', logsSnapshot.size)
      
      // Filtreye göre tarih hesapla
      let filterDate = null
      if (filter === 'today') {
        filterDate = new Date()
        filterDate.setHours(0, 0, 0, 0)
      } else if (filter === 'week') {
        filterDate = new Date()
        filterDate.setDate(filterDate.getDate() - 7)
      } else if (filter === 'month') {
        filterDate = new Date()
        filterDate.setMonth(filterDate.getMonth() - 1)
      }
      
      console.log('📅 Filtre:', filter, 'Tip:', typeFilter, 'Tarih:', filterDate?.toISOString())
      
      // Aktiviteleri işle
      const allLogs = []
      let todayCount = 0
      let weekCount = 0
      const typeCount = {}
      
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const weekAgo = new Date()
      weekAgo.setDate(weekAgo.getDate() - 7)
      
      logsSnapshot.docs.forEach(doc => {
        const data = doc.data()
        const activityDate = toDate(data.timestamp || data.createdAt)
        
        if (!activityDate) {
          console.log('⚠️ timestamp yok:', data.userName || doc.id)
          return
        }
        
        // İstatistikler
        if (activityDate >= today) todayCount++
        if (activityDate >= weekAgo) weekCount++
        
        // Tip sayacı
        const type = data.type || 'unknown'
        typeCount[type] = (typeCount[type] || 0) + 1
        
        // Filtreleme - tarih
        if (filterDate && activityDate < filterDate) {
          return
        }
        
        // Filtreleme - tip
        if (typeFilter !== 'all' && data.type !== typeFilter) {
          return
        }
        
        const config = activityConfig[type] || { icon: '❓', color: 'text-gray-600', label: type }
        
        allLogs.push({
          id: doc.id,
          type: data.type || 'unknown',
          user: data.userName || 'Anonim',
          userId: data.userId || '-',
          zodiac: data.zodiacSign || '⭐',
          action: data.action || 'Aktivite',
          metadata: data.metadata || {},
          createdAt: activityDate,
          timestamp: activityDate.getTime(),
          icon: config.icon,
          color: config.color,
          label: config.label
        })
      })
      
      // Tarihe göre sırala (en yeni önce)
      allLogs.sort((a, b) => b.timestamp - a.timestamp)
      
      console.log('📊 İstatistikler:')
      console.log('  - Toplam:', logsSnapshot.size)
      console.log('  - Bugün:', todayCount)
      console.log('  - Son 7 gün:', weekCount)
      console.log('  - Tip dağılımı:', typeCount)
      console.log('  - Filtrelenmiş:', allLogs.length)
      
      setStats({
        total: logsSnapshot.size,
        today: todayCount,
        week: weekCount,
        byType: typeCount
      })
      setLogs(allLogs)
    } catch (error) {
      console.error('❌ Aktivite logları yükleme hatası:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl">
              <Zap className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Aktivite Logları</h1>
              <p className="text-sm text-gray-500">Gerçek zamanlı kullanıcı aktiviteleri</p>
            </div>
          </div>
          <button
            onClick={loadActivityLogs}
            className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            Yenile
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-4 text-white">
          <div className="flex items-center justify-between mb-2">
            <Activity className="w-5 h-5 opacity-80" />
            <span className="text-2xl font-bold">{stats.total}</span>
          </div>
          <p className="text-sm opacity-90">Toplam Aktivite</p>
        </div>

        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-4 text-white">
          <div className="flex items-center justify-between mb-2">
            <Calendar className="w-5 h-5 opacity-80" />
            <span className="text-2xl font-bold">{stats.today}</span>
          </div>
          <p className="text-sm opacity-90">Bugün</p>
        </div>

        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl p-4 text-white">
          <div className="flex items-center justify-between mb-2">
            <Clock className="w-5 h-5 opacity-80" />
            <span className="text-2xl font-bold">{stats.week}</span>
          </div>
          <p className="text-sm opacity-90">Son 7 Gün</p>
        </div>

        <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl p-4 text-white">
          <div className="flex items-center justify-between mb-2">
            <Zap className="w-5 h-5 opacity-80" />
            <span className="text-2xl font-bold">{Object.keys(stats.byType).length}</span>
          </div>
          <p className="text-sm opacity-90">Aktivite Tipi</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl border border-gray-200 p-4 mb-6">
        <div className="flex flex-wrap gap-4">
          {/* Time Filter */}
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-gray-500" />
            <span className="text-sm font-medium text-gray-700">Zaman:</span>
            <div className="flex gap-2">
              {['all', 'today', 'week', 'month'].map(f => (
                <button
                  key={f}
                  onClick={() => setFilter(f)}
                  className={`px-3 py-1 rounded-lg text-sm font-medium transition-colors ${
                    filter === f
                      ? 'bg-purple-500 text-white'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  {f === 'all' ? 'Tümü' : f === 'today' ? 'Bugün' : f === 'week' ? 'Son 7 Gün' : 'Son 30 Gün'}
                </button>
              ))}
            </div>
          </div>

          {/* Type Filter */}
          <div className="flex items-center gap-2">
            <span className="text-sm font-medium text-gray-700">Tip:</span>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="px-3 py-1 rounded-lg text-sm font-medium bg-gray-100 text-gray-600 border-none focus:ring-2 focus:ring-purple-500"
            >
              <option value="all">Tümü</option>
              {Object.entries(activityConfig).map(([key, config]) => (
                <option key={key} value={key}>
                  {config.icon} {config.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Activity Table */}
      <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-500"></div>
          </div>
        ) : logs.length === 0 ? (
          <div className="text-center py-12">
            <Activity className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-gray-500">Henüz aktivite yok</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Kullanıcı
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Aktivite
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Detay
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Zaman
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {logs.map((log) => (
                  <tr key={log.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center text-white font-bold">
                          {log.zodiac}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">{log.user}</div>
                          <div className="text-sm text-gray-500">{log.zodiac}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <span className="text-2xl">{log.icon}</span>
                        <div>
                          <div className={`text-sm font-medium ${log.color}`}>{log.label}</div>
                          <div className="text-xs text-gray-500">{log.action}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">
                        {log.metadata.cardName && (
                          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                            {log.metadata.cardName}
                          </span>
                        )}
                        {log.metadata.sign1 && log.metadata.sign2 && (
                          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-pink-100 text-pink-800">
                            {log.metadata.sign1} + {log.metadata.sign2}
                          </span>
                        )}
                        {log.metadata.price && (
                          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                            ₺{log.metadata.price}
                          </span>
                        )}
                        {log.metadata.risingSign && (
                          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            Yükselen: {log.metadata.risingSign}
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        {format(log.createdAt, 'dd MMM yyyy', { locale: tr })}
                      </div>
                      <div className="text-sm text-gray-500">
                        {format(log.createdAt, 'HH:mm:ss', { locale: tr })}
                      </div>
                      <div className="text-xs text-gray-400 mt-1">
                        {getTimeAgo(log.createdAt)}
                      </div>
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
