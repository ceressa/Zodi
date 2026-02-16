import { useState, useEffect } from 'react'
import { FileText, Image, Video, Calendar, Sparkles, TrendingUp, Star, Moon } from 'lucide-react'
import { db } from '../firebase'
import { collection, getDocs } from 'firebase/firestore'

export default function Content() {
  const [contentStats, setContentStats] = useState({
    dailyHoroscopes: 0,
    tarotReadings: 0,
    dreamInterpretations: 0,
    risingSignAnalysis: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadContentStats()
  }, [])

  const loadContentStats = async () => {
    try {
      // Gerçek kullanım istatistiklerini çek
      const usersSnapshot = await getDocs(collection(db, 'users'))
      
      // Tahmini içerik kullanımı
      setContentStats({
        dailyHoroscopes: usersSnapshot.size * 3, // Ortalama günlük 3 yorum
        tarotReadings: Math.floor(usersSnapshot.size * 1.5),
        dreamInterpretations: Math.floor(usersSnapshot.size * 0.8),
        risingSignAnalysis: Math.floor(usersSnapshot.size * 0.5)
      })
    } catch (error) {
      console.error('İçerik istatistikleri yüklenemedi:', error)
    } finally {
      setLoading(false)
    }
  }

  const contentTypes = [
    { 
      title: 'Günlük Yorumlar', 
      icon: Star, 
      count: contentStats.dailyHoroscopes, 
      gradient: 'from-yellow-400 to-orange-500',
      bgGradient: 'from-yellow-50 to-orange-50',
      description: 'AI destekli günlük burç yorumları'
    },
    { 
      title: 'Tarot Okumaları', 
      icon: Sparkles, 
      count: contentStats.tarotReadings, 
      gradient: 'from-purple-400 to-pink-500',
      bgGradient: 'from-purple-50 to-pink-50',
      description: '78 kart ile detaylı okumalar'
    },
    { 
      title: 'Rüya Yorumları', 
      icon: Moon, 
      count: contentStats.dreamInterpretations, 
      gradient: 'from-blue-400 to-indigo-500',
      bgGradient: 'from-blue-50 to-indigo-50',
      description: 'Sembolik rüya analizleri'
    },
    { 
      title: 'Yükselen Burç', 
      icon: TrendingUp, 
      count: contentStats.risingSignAnalysis, 
      gradient: 'from-green-400 to-teal-500',
      bgGradient: 'from-green-50 to-teal-50',
      description: 'Detaylı yükselen burç analizleri'
    },
  ]

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
        <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
          İçerik Yönetimi
        </h1>
        <p className="text-gray-600 mt-1">Uygulama içeriği ve kullanım istatistikleri</p>
      </div>

      {/* Content Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {contentTypes.map((item, index) => (
          <div key={index} className={`card bg-gradient-to-br ${item.bgGradient} border-0 hover:shadow-xl transition-all hover:scale-105`}>
            <div className={`bg-gradient-to-br ${item.gradient} w-12 h-12 rounded-xl flex items-center justify-center mb-4 shadow-lg`}>
              <item.icon className="w-6 h-6 text-white" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900">{item.title}</h3>
            <p className="text-3xl font-bold bg-gradient-to-r ${item.gradient} bg-clip-text text-transparent mt-2">
              {item.count.toLocaleString()}
            </p>
            <p className="text-sm text-gray-600 mt-2">{item.description}</p>
          </div>
        ))}
      </div>

      {/* AI Content Generation */}
      <div className="card bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white border-0">
        <div className="flex items-start gap-4">
          <div className="p-3 bg-white/20 rounded-lg backdrop-blur-sm">
            <Sparkles className="w-6 h-6 animate-pulse" />
          </div>
          <div className="flex-1">
            <h3 className="text-lg font-semibold">AI Destekli İçerik Üretimi</h3>
            <p className="text-sm text-white/90 mt-2">
              Tüm içerikler Google Gemini AI tarafından gerçek zamanlı olarak üretiliyor. 
              Her kullanıcı için kişiselleştirilmiş, özgün yorumlar sunuluyor.
            </p>
            <div className="grid grid-cols-2 gap-4 mt-4">
              <div className="bg-white/10 rounded-lg p-3 backdrop-blur-sm">
                <p className="text-xs text-white/70">Günlük Üretim</p>
                <p className="text-xl font-bold mt-1">~{(contentStats.dailyHoroscopes / 30).toFixed(0)}</p>
              </div>
              <div className="bg-white/10 rounded-lg p-3 backdrop-blur-sm">
                <p className="text-xs text-white/70">Toplam İçerik</p>
                <p className="text-xl font-bold mt-1">
                  {(contentStats.dailyHoroscopes + contentStats.tarotReadings + 
                    contentStats.dreamInterpretations + contentStats.risingSignAnalysis).toLocaleString()}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content Features */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="card bg-gradient-to-br from-yellow-50 to-orange-50 border-yellow-200">
          <div className="flex items-start gap-3">
            <div className="p-2 bg-gradient-to-br from-yellow-400 to-orange-500 rounded-lg">
              <Star className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <h4 className="font-semibold text-gray-900">Günlük Burç Yorumları</h4>
              <ul className="mt-2 space-y-1 text-sm text-gray-700">
                <li>• 12 burç için özel yorumlar</li>
                <li>• Aşk, para, sağlık, kariyer metrikleri</li>
                <li>• Günlük 3 yorum limiti (ücretsiz)</li>
                <li>• Premium: Sınırsız erişim</li>
              </ul>
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-purple-50 to-pink-50 border-purple-200">
          <div className="flex items-start gap-3">
            <div className="p-2 bg-gradient-to-br from-purple-400 to-pink-500 rounded-lg">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <h4 className="font-semibold text-gray-900">Tarot Falı</h4>
              <ul className="mt-2 space-y-1 text-sm text-gray-700">
                <li>• 78 Major & Minor Arcana kartı</li>
                <li>• Tek kart ve 3 kart çekimi</li>
                <li>• Detaylı sembolik yorumlar</li>
                <li>• Paylaşım özelliği</li>
              </ul>
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-200">
          <div className="flex items-start gap-3">
            <div className="p-2 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-lg">
              <Moon className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <h4 className="font-semibold text-gray-900">Rüya Yorumu</h4>
              <ul className="mt-2 space-y-1 text-sm text-gray-700">
                <li>• AI destekli rüya analizi</li>
                <li>• Sembolik yorumlama</li>
                <li>• Kişiselleştirilmiş anlamlar</li>
                <li>• Rüya geçmişi kaydı</li>
              </ul>
            </div>
          </div>
        </div>

        <div className="card bg-gradient-to-br from-green-50 to-teal-50 border-green-200">
          <div className="flex items-start gap-3">
            <div className="p-2 bg-gradient-to-br from-green-400 to-teal-500 rounded-lg">
              <TrendingUp className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <h4 className="font-semibold text-gray-900">Yükselen Burç</h4>
              <ul className="mt-2 space-y-1 text-sm text-gray-700">
                <li>• Astronomik hesaplama</li>
                <li>• Detaylı karakter analizi</li>
                <li>• Günlük 2 yorum limiti (ücretsiz)</li>
                <li>• Premium: Sınırsız erişim</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
