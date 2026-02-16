import { useState, useEffect } from 'react'
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, BarChart, Bar, XAxis, YAxis, CartesianGrid } from 'recharts'
import { db } from '../firebase'
import { collection, getDocs } from 'firebase/firestore'
import { TrendingUp, Users, Star, Activity } from 'lucide-react'

export default function Analytics() {
  const [zodiacData, setZodiacData] = useState([])
  const [stats, setStats] = useState({
    totalUsers: 0,
    premiumUsers: 0,
    mostPopularZodiac: '',
    leastPopularZodiac: ''
  })
  const [loading, setLoading] = useState(true)

  const zodiacColors = {
    '♈': '#FF6B6B', '♉': '#4ECDC4', '♊': '#FFE66D',
    '♋': '#95E1D3', '♌': '#F38181', '♍': '#AA96DA',
    '♎': '#FCBAD3', '♏': '#A8D8EA', '♐': '#FFD93D',
    '♑': '#6BCB77', '♒': '#4D96FF', '♓': '#C780FA'
  }

  const zodiacNames = {
    '♈': 'Koç', '♉': 'Boğa', '♊': 'İkizler',
    '♋': 'Yengeç', '♌': 'Aslan', '♍': 'Başak',
    '♎': 'Terazi', '♏': 'Akrep', '♐': 'Yay',
    '♑': 'Oğlak', '♒': 'Kova', '♓': 'Balık'
  }

  useEffect(() => {
    loadZodiacDistribution()
  }, [])

  const loadZodiacDistribution = async () => {
    try {
      const usersSnapshot = await getDocs(collection(db, 'users'))
      const zodiacCount = {}
      let premiumCount = 0
      
      usersSnapshot.docs.forEach(doc => {
        const data = doc.data()
        const zodiac = data.zodiacSign
        if (zodiac) {
          zodiacCount[zodiac] = (zodiacCount[zodiac] || 0) + 1
        }
        if (data.isPremium) premiumCount++
      })

      const data = Object.entries(zodiacCount)
        .map(([sign, count]) => ({
          name: zodiacNames[sign] || sign,
          sign: sign,
          value: count,
          color: zodiacColors[sign] || '#999'
        }))
        .sort((a, b) => b.value - a.value)

      const mostPopular = data[0]?.name || '-'
      const leastPopular = data[data.length - 1]?.name || '-'

      setZodiacData(data)
      setStats({
        totalUsers: usersSnapshot.size,
        premiumUsers: premiumCount,
        mostPopularZodiac: mostPopular,
        leastPopularZodiac: leastPopular
      })
    } catch (error) {
      console.error('Burç dağılımı yüklenemedi:', error)
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
        <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
          Analitik
        </h1>
        <p className="text-gray-600 mt-1">Kullanıcı dağılımı ve istatistikler</p>
      </div>

      {/* Quick Stats */}
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

        <div className="card bg-gradient-to-br from-purple-500 to-purple-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm">Premium Üye</p>
              <p className="text-3xl font-bold mt-2">{stats.premiumUsers.toLocaleString()}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <Star className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-green-500 to-emerald-600 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm">En Popüler</p>
              <p className="text-2xl font-bold mt-2">{stats.mostPopularZodiac}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <TrendingUp className="w-8 h-8" />
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-orange-500 to-red-500 text-white border-0 hover:shadow-xl transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-orange-100 text-sm">En Az Popüler</p>
              <p className="text-2xl font-bold mt-2">{stats.leastPopularZodiac}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-lg">
              <Activity className="w-8 h-8" />
            </div>
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Pie Chart */}
        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Burç Dağılımı (Pasta Grafik)</h3>
          {zodiacData.length > 0 ? (
            <ResponsiveContainer width="100%" height={350}>
              <PieChart>
                <Pie
                  data={zodiacData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {zodiacData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <p className="text-center text-gray-500 py-12">Henüz veri yok</p>
          )}
        </div>

        {/* Bar Chart */}
        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Burç Dağılımı (Çubuk Grafik)</h3>
          {zodiacData.length > 0 ? (
            <ResponsiveContainer width="100%" height={350}>
              <BarChart data={zodiacData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" angle={-45} textAnchor="end" height={80} />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" radius={[8, 8, 0, 0]}>
                  {zodiacData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <p className="text-center text-gray-500 py-12">Henüz veri yok</p>
          )}
        </div>
      </div>

      {/* Zodiac List */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Detaylı Burç İstatistikleri</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {zodiacData.map((zodiac, index) => (
            <div 
              key={index} 
              className="p-4 rounded-lg border-2 hover:shadow-lg transition-all cursor-pointer"
              style={{ borderColor: zodiac.color, backgroundColor: `${zodiac.color}10` }}
            >
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-3xl">{zodiac.sign}</span>
                  <span className="font-semibold text-gray-900">{zodiac.name}</span>
                </div>
                <div 
                  className="w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-sm"
                  style={{ backgroundColor: zodiac.color }}
                >
                  {index + 1}
                </div>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-2xl font-bold text-gray-900">{zodiac.value}</span>
                <span className="text-sm text-gray-600">
                  {((zodiac.value / stats.totalUsers) * 100).toFixed(1)}%
                </span>
              </div>
              <div className="mt-2 w-full bg-gray-200 rounded-full h-2">
                <div 
                  className="h-2 rounded-full transition-all"
                  style={{ 
                    width: `${(zodiac.value / stats.totalUsers) * 100}%`,
                    backgroundColor: zodiac.color
                  }}
                ></div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Info Card */}
      <div className="card bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white border-0">
        <div className="flex items-start gap-3">
          <div className="p-2 bg-white/20 rounded-lg backdrop-blur-sm">
            <Activity className="w-5 h-5" />
          </div>
          <div>
            <h4 className="font-semibold">💡 Analitik İpuçları</h4>
            <p className="text-sm text-white/90 mt-1">
              Kullanıcılar uygulamada burç seçtikçe bu grafikler otomatik güncellenir. 
              En popüler burçlar için özel kampanyalar düzenleyebilirsiniz.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
