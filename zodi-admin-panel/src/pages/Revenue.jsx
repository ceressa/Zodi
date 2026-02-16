import { useState, useEffect } from 'react'
import { DollarSign, TrendingUp, CreditCard, Users } from 'lucide-react'
import StatCard from '../components/StatCard'
import { db } from '../firebase'
import { collection, query, where, getDocs } from 'firebase/firestore'

export default function Revenue() {
  const [stats, setStats] = useState({
    totalRevenue: 0,
    premiumRevenue: 0,
    premiumUsers: 0,
    conversionRate: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadRevenueStats()
  }, [])

  const loadRevenueStats = async () => {
    try {
      const usersSnapshot = await getDocs(collection(db, 'users'))
      const totalUsers = usersSnapshot.size

      const premiumQuery = query(
        collection(db, 'users'),
        where('isPremium', '==', true)
      )
      const premiumSnapshot = await getDocs(premiumQuery)
      const premiumUsers = premiumSnapshot.size

      const premiumPrice = 49.99
      const premiumRevenue = premiumUsers * premiumPrice
      const conversionRate = totalUsers > 0 ? ((premiumUsers / totalUsers) * 100).toFixed(1) : 0

      setStats({
        totalRevenue: premiumRevenue,
        premiumRevenue,
        premiumUsers,
        conversionRate
      })
    } catch (error) {
      console.error('Gelir istatistikleri yüklenemedi:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
          Gelir Yönetimi
        </h1>
        <p className="text-gray-600 mt-1">Finansal performans ve gelir analizi</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="card bg-gradient-to-br from-green-500 to-emerald-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm">Toplam Gelir</p>
              <p className="text-3xl font-bold mt-2">₺{stats.totalRevenue.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <DollarSign className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-blue-500 to-blue-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm">Premium Gelir</p>
              <p className="text-3xl font-bold mt-2">₺{stats.premiumRevenue.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <CreditCard className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-purple-500 to-purple-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm">Premium Üye</p>
              <p className="text-3xl font-bold mt-2">{stats.premiumUsers.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <TrendingUp className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-orange-500 to-red-500 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-orange-100 text-sm">Dönüşüm Oranı</p>
              <p className="text-3xl font-bold mt-2">{stats.conversionRate}%</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <Users className="w-8 h-8" />
            </div>
          </div>
        </div>
      </div>

      {/* Revenue Details */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card bg-gradient-to-br from-green-50 to-emerald-50 border-green-200 hover:shadow-lg transition-all">
          <div className="flex items-center justify-between mb-4">
            <div className="p-3 bg-gradient-to-br from-green-400 to-emerald-500 rounded-xl shadow-lg">
              <CreditCard className="w-6 h-6 text-white" />
            </div>
            <span className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full font-medium">
              Aktif
            </span>
          </div>
          <p className="text-sm text-gray-600">Premium Üyelik Fiyatı</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">₺49.99</p>
          <p className="text-xs text-gray-500 mt-2">Tek seferlik ödeme</p>
        </div>
        
        <div className="card bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-200 hover:shadow-lg transition-all">
          <div className="flex items-center justify-between mb-4">
            <div className="p-3 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-xl shadow-lg">
              <Users className="w-6 h-6 text-white" />
            </div>
            <span className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded-full font-medium">
              {stats.premiumUsers} Üye
            </span>
          </div>
          <p className="text-sm text-gray-600">Aktif Premium Üye</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">{stats.premiumUsers}</p>
          <p className="text-xs text-gray-500 mt-2">Toplam kullanıcıların %{stats.conversionRate}'i</p>
        </div>

        <div className="card bg-gradient-to-br from-purple-50 to-pink-50 border-purple-200 hover:shadow-lg transition-all">
          <div className="flex items-center justify-between mb-4">
            <div className="p-3 bg-gradient-to-br from-purple-400 to-pink-500 rounded-xl shadow-lg">
              <DollarSign className="w-6 h-6 text-white" />
            </div>
            <span className="text-xs bg-purple-100 text-purple-700 px-2 py-1 rounded-full font-medium">
              Tahmini
            </span>
          </div>
          <p className="text-sm text-gray-600">Tahmini Aylık Gelir</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">₺{stats.totalRevenue.toLocaleString()}</p>
          <p className="text-xs text-gray-500 mt-2">Premium üyeliklerden</p>
        </div>
      </div>

      {/* Monetization Strategy */}
      <div className="card bg-gradient-to-r from-yellow-400 via-orange-400 to-red-400 text-white border-0">
        <div className="flex items-start gap-3">
          <div className="p-2 bg-white/20 rounded-lg backdrop-blur-sm">
            <TrendingUp className="w-5 h-5" />
          </div>
          <div className="flex-1">
            <h4 className="font-semibold text-lg mb-3">💰 Para Tuzakları Stratejisi</h4>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
                <p className="text-sm text-white/90 mb-2">Günlük Yorum Limiti</p>
                <p className="text-2xl font-bold">3 / gün</p>
                <p className="text-xs text-white/70 mt-1">Ücretsiz kullanıcılar için</p>
              </div>
              <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
                <p className="text-sm text-white/90 mb-2">Kozmik Takvim</p>
                <p className="text-2xl font-bold">3 gün</p>
                <p className="text-xs text-white/70 mt-1">Ücretsiz önizleme</p>
              </div>
              <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
                <p className="text-sm text-white/90 mb-2">Yükselen Burç</p>
                <p className="text-2xl font-bold">2 / gün</p>
                <p className="text-xs text-white/70 mt-1">Detaylı yorum limiti</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Revenue Breakdown */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Gelir Kaynakları</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-gradient-to-r from-green-50 to-emerald-50 rounded-lg">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gradient-to-br from-green-400 to-emerald-500 rounded-lg flex items-center justify-center">
                  <CreditCard className="w-5 h-5 text-white" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900">Premium Üyelikler</p>
                  <p className="text-xs text-gray-600">{stats.premiumUsers} aktif üye</p>
                </div>
              </div>
              <p className="text-lg font-bold text-green-600">₺{stats.premiumRevenue.toLocaleString()}</p>
            </div>

            <div className="flex items-center justify-between p-3 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-lg flex items-center justify-center">
                  <TrendingUp className="w-5 h-5 text-white" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900">Reklam Gelirleri</p>
                  <p className="text-xs text-gray-600">Ücretsiz kullanıcılardan</p>
                </div>
              </div>
              <p className="text-lg font-bold text-blue-600">₺0</p>
            </div>
          </div>
        </div>

        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Büyüme Metrikleri</h3>
          <div className="space-y-4">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-gray-600">Dönüşüm Oranı</span>
                <span className="text-sm font-semibold text-gray-900">{stats.conversionRate}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-gradient-to-r from-green-400 to-emerald-500 h-2 rounded-full transition-all"
                  style={{ width: `${Math.min(stats.conversionRate, 100)}%` }}
                ></div>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-gray-600">Premium Penetrasyon</span>
                <span className="text-sm font-semibold text-gray-900">{stats.conversionRate}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-gradient-to-r from-purple-400 to-pink-500 h-2 rounded-full transition-all"
                  style={{ width: `${Math.min(stats.conversionRate, 100)}%` }}
                ></div>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-gray-600">Hedef: %10</span>
                <span className="text-sm font-semibold text-gray-900">
                  {((stats.conversionRate / 10) * 100).toFixed(0)}%
                </span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-gradient-to-r from-yellow-400 to-orange-500 h-2 rounded-full transition-all"
                  style={{ width: `${Math.min((stats.conversionRate / 10) * 100, 100)}%` }}
                ></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Tips */}
      <div className="card bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white border-0">
        <div className="flex items-start gap-3">
          <div className="p-2 bg-white/20 rounded-lg backdrop-blur-sm">
            <TrendingUp className="w-5 h-5" />
          </div>
          <div>
            <h4 className="font-semibold">Gelir Artırma İpuçları</h4>
            <ul className="mt-2 space-y-1 text-sm text-white/90">
              <li>✅ Para tuzakları aktif - Günlük yorum limiti çalışıyor</li>
              <li>✅ Kozmik takvim paywall aktif</li>
              <li>✅ Yükselen burç detaylı yorum limiti aktif</li>
              <li>✅ Reklam geliri sistemi hazır</li>
              <li>💡 Premium özellikleri vurgulayın</li>
              <li>💡 Kullanıcı deneyimini iyileştirin</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}
