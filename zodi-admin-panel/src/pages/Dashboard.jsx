import { useState, useEffect } from 'react'
import { Users, DollarSign, Eye, TrendingUp, Activity, Sparkles, Crown, UserPlus } from 'lucide-react'
import StatCard from '../components/StatCard'
import { db } from '../firebase'
import { collection, query, where, getDocs, limit, Timestamp, onSnapshot, orderBy } from 'firebase/firestore'

// Helper function to safely convert Firestore timestamp to Date
const toDate = (timestamp) => {
  if (!timestamp) return null
  
  try {
    // Firestore Timestamp object
    if (timestamp.toDate && typeof timestamp.toDate === 'function') {
      return timestamp.toDate()
    }
    
    // Timestamp object with seconds
    if (timestamp.seconds) {
      return new Date(timestamp.seconds * 1000)
    }
    
    // Already a Date object
    if (timestamp instanceof Date) {
      return timestamp
    }
    
    // Try to parse as string/number
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

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeUsers: 0,
    revenue: 0,
    premiumUsers: 0
  })
  const [loading, setLoading] = useState(true)
  const [recentActivities, setRecentActivities] = useState([])
  const [liveActivity, setLiveActivity] = useState(null)

  useEffect(() => {
    loadStats()
    loadRecentActivities()
    
    // Canlı aktivite dinleyicisi - sadece gerçekten yeni eklenen kullanıcılar için
    let isFirstLoad = true
    const unsubscribe = onSnapshot(
      query(collection(db, 'users'), orderBy('createdAt', 'desc'), limit(1)),
      (snapshot) => {
        // İlk yüklemede mevcut verileri gösterme
        if (isFirstLoad) {
          isFirstLoad = false
          return
        }
        
        snapshot.docChanges().forEach((change) => {
          if (change.type === 'added') {
            const data = change.doc.data()
            const createdDate = toDate(data.createdAt)
            const now = new Date()
            
            // Sadece son 10 saniyede oluşturulan kullanıcıları göster
            if (createdDate && (now - createdDate) < 10000) {
              setLiveActivity({
                user: data.name || 'Yeni Kullanıcı',
                action: data.isPremium ? 'Premium üyelik satın aldı! 🎉' : 'Uygulamaya katıldı! 👋',
                time: 'Şimdi',
                type: data.isPremium ? 'premium' : 'signup',
                isNew: true
              })
              
              // Aktivite listesini yenile
              loadRecentActivities()
              
              // 5 saniye sonra animasyonu kaldır
              setTimeout(() => {
                setLiveActivity(prev => prev ? { ...prev, isNew: false } : null)
              }, 5000)
            }
          }
        })
      }
    )
    
    // Her 30 saniyede bir aktiviteleri yenile
    const interval = setInterval(loadRecentActivities, 30000)
    
    return () => {
      unsubscribe()
      clearInterval(interval)
    }
  }, [])

  const loadStats = async () => {
    try {
      // Toplam kullanıcılar
      const usersSnapshot = await getDocs(collection(db, 'users'))
      const totalUsers = usersSnapshot.size

      // Premium kullanıcılar
      const premiumQuery = query(
        collection(db, 'users'),
        where('isPremium', '==', true)
      )
      const premiumSnapshot = await getDocs(premiumQuery)
      const premiumUsers = premiumSnapshot.size

      // Aktif kullanıcılar (son 7 gün)
      const sevenDaysAgo = new Date()
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)
      const activeQuery = query(
        collection(db, 'users'),
        where('lastActive', '>=', Timestamp.fromDate(sevenDaysAgo))
      )
      const activeSnapshot = await getDocs(activeQuery)
      const activeUsers = activeSnapshot.size

      setStats({
        totalUsers,
        activeUsers,
        revenue: premiumUsers * 49.99,
        premiumUsers
      })
    } catch (error) {
      console.error('Stats yüklenemedi:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadRecentActivities = async () => {
    try {
      // Tüm kullanıcıları çek
      const usersSnapshot = await getDocs(collection(db, 'users'))
      
      // Son 24 saatteki kullanıcıları filtrele
      const oneDayAgo = new Date()
      oneDayAgo.setHours(oneDayAgo.getHours() - 24)
      
      console.log('🔍 DEBUG: Son 24 saat kontrolü')
      console.log('Şimdiki zaman:', new Date().toISOString())
      console.log('24 saat önce:', oneDayAgo.toISOString())
      
      const recentUsers = usersSnapshot.docs
        .map(doc => ({
          id: doc.id,
          ...doc.data()
        }))
        .filter(user => {
          if (!user.createdAt) {
            console.log('❌ createdAt yok:', user.name || user.id)
            return false
          }
          const createdDate = toDate(user.createdAt)
          if (!createdDate) {
            console.log('❌ Tarih parse edilemedi:', user.name || user.id, user.createdAt)
            return false
          }
          
          const isRecent = createdDate >= oneDayAgo
          console.log(
            isRecent ? '✅' : '❌',
            user.name || user.id,
            'Oluşturulma:',
            createdDate.toISOString(),
            'Fark:',
            Math.floor((new Date() - createdDate) / 1000 / 60 / 60),
            'saat'
          )
          
          return isRecent
        })
        .sort((a, b) => {
          const dateA = toDate(a.createdAt)
          const dateB = toDate(b.createdAt)
          if (!dateA || !dateB) return 0
          return dateB - dateA // En yeni önce
        })
        .slice(0, 10) // İlk 10'u al
      
      console.log('📊 Toplam kullanıcı:', usersSnapshot.size)
      console.log('📊 Son 24 saatte:', recentUsers.length)
      
      const activities = recentUsers.map(data => {
        let timeAgo = 'Yakın zamanda'
        
        if (data.createdAt) {
          try {
            const date = toDate(data.createdAt)
            timeAgo = getTimeAgo(date)
          } catch (e) {
            console.error('Tarih parse hatası:', e)
            timeAgo = 'Yakın zamanda'
          }
        }
        
        return {
          user: data.name || 'Anonim',
          action: data.isPremium ? 'Premium üyelik satın aldı' : 'Uygulamaya katıldı',
          time: timeAgo,
          type: data.isPremium ? 'premium' : 'signup',
          zodiac: data.zodiacSign || '⭐'
        }
      })
      
      setRecentActivities(activities)
    } catch (error) {
      console.error('Aktiviteler yüklenemedi:', error)
      setRecentActivities([])
    }
  }

  const getTimeAgo = (date) => {
    if (!date || !(date instanceof Date) || isNaN(date.getTime())) {
      return 'Yakın zamanda'
    }
    
    const seconds = Math.floor((new Date() - date) / 1000)
    
    // Negatif değer kontrolü (gelecek tarih)
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

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
            Dashboard
          </h1>
          <p className="text-gray-600 mt-1">Zodi uygulamanızın gerçek zamanlı görünümü</p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => {
              console.clear()
              loadRecentActivities()
            }}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm font-medium"
          >
            🔍 Debug Logları
          </button>
          <div className="flex items-center gap-2 px-4 py-2 bg-green-50 border border-green-200 rounded-lg">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            <span className="text-sm font-medium text-green-700">Canlı</span>
          </div>
        </div>
      </div>

      {/* Canlı Aktivite Banner */}
      {liveActivity && (
        <div className={`card bg-gradient-to-r from-purple-500 to-pink-500 text-white border-0 transform transition-all duration-500 ${
          liveActivity.isNew ? 'scale-105 shadow-2xl' : 'scale-100'
        }`}>
          <div className="flex items-center gap-4">
            <div className="p-3 bg-white/20 rounded-full backdrop-blur-sm">
              {liveActivity.type === 'premium' ? (
                <Crown className="w-6 h-6 text-yellow-300 animate-bounce" />
              ) : (
                <UserPlus className="w-6 h-6 animate-bounce" />
              )}
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <Sparkles className="w-4 h-4 animate-pulse" />
                <p className="font-semibold">Canlı Aktivite</p>
              </div>
              <p className="text-sm mt-1 text-white/90">
                <span className="font-medium">{liveActivity.user}</span> {liveActivity.action}
              </p>
            </div>
            <span className="text-xs bg-white/20 px-3 py-1 rounded-full">{liveActivity.time}</span>
          </div>
        </div>
      )}

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="card bg-gradient-to-br from-blue-500 to-blue-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm">Toplam Kullanıcı</p>
              <p className="text-3xl font-bold mt-2">{stats.totalUsers.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <Users className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-green-500 to-green-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm">Aktif Kullanıcı (7 gün)</p>
              <p className="text-3xl font-bold mt-2">{stats.activeUsers.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <Activity className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-purple-500 to-purple-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm">Tahmini Gelir</p>
              <p className="text-3xl font-bold mt-2">₺{stats.revenue.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <DollarSign className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-yellow-500 to-orange-500 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-yellow-100 text-sm">Premium Üye</p>
              <p className="text-3xl font-bold mt-2">{stats.premiumUsers.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <Crown className="w-8 h-8" />
            </div>
          </div>
        </div>
      </div>

      {/* Son Aktiviteler */}
      <div className="card">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">Son Kayıtlar</h3>
          <div className="flex items-center gap-2 text-sm text-gray-500">
            <Activity className="w-4 h-4" />
            <span>Son 24 saat</span>
          </div>
        </div>
        {recentActivities.length > 0 ? (
          <div className="space-y-3">
            {recentActivities.map((activity, index) => (
              <div key={index} className="flex items-center justify-between p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex items-center gap-3">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                    activity.type === 'premium' 
                      ? 'bg-gradient-to-br from-yellow-400 to-orange-500' 
                      : 'bg-gradient-to-br from-green-400 to-blue-500'
                  }`}>
                    {activity.type === 'premium' ? (
                      <Crown className="w-5 h-5 text-white" />
                    ) : (
                      <UserPlus className="w-5 h-5 text-white" />
                    )}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-medium text-gray-900">{activity.user}</p>
                      <span className="text-lg">{activity.zodiac}</span>
                    </div>
                    <p className="text-sm text-gray-600">{activity.action}</p>
                  </div>
                </div>
                <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded">{activity.time}</span>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-8">
            <p className="text-gray-500">Son 24 saatte yeni kayıt yok</p>
            <p className="text-sm text-gray-400 mt-1">Yeni kullanıcılar katıldığında burada görünecek</p>
          </div>
        )}
      </div>

      {/* Info Card */}
      <div className="card bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white border-0">
        <div className="flex items-start gap-4">
          <div className="p-3 bg-white/20 rounded-lg backdrop-blur-sm">
            <Sparkles className="w-6 h-6" />
          </div>
          <div className="flex-1">
            <h3 className="text-lg font-semibold">Gerçek Zamanlı Veriler</h3>
            <p className="text-sm text-white/90 mt-1">
              Bu panel Firebase Firestore'dan gerçek zamanlı veri çekiyor. 
              Kullanıcılar uygulamayı kullandıkça veriler otomatik güncelleniyor.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
