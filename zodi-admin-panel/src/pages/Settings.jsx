import { useState } from 'react'
import { Bell, Shield, Database, Palette, Zap, Globe, Lock, Smartphone } from 'lucide-react'

export default function Settings() {
  const [settings, setSettings] = useState({
    notifications: true,
    autoBackup: true,
    darkMode: false,
    analytics: true,
    premiumPrice: 49.99,
    dailyLimit: 3,
    risingSignLimit: 2
  })

  const settingsCategories = [
    { 
      title: 'Bildirimler', 
      icon: Bell, 
      gradient: 'from-blue-400 to-blue-600',
      bgGradient: 'from-blue-50 to-blue-100',
      description: 'Push bildirim ve e-posta ayarları',
      items: [
        { label: 'Push Bildirimleri', value: settings.notifications, key: 'notifications' },
        { label: 'E-posta Bildirimleri', value: true, key: 'emailNotifications' },
        { label: 'Günlük Hatırlatıcılar', value: true, key: 'dailyReminders' }
      ]
    },
    { 
      title: 'Güvenlik', 
      icon: Shield, 
      gradient: 'from-green-400 to-green-600',
      bgGradient: 'from-green-50 to-green-100',
      description: 'Güvenlik ve gizlilik ayarları',
      items: [
        { label: 'İki Faktörlü Doğrulama', value: false, key: 'twoFactor' },
        { label: 'Veri Şifreleme', value: true, key: 'encryption' },
        { label: 'Oturum Zaman Aşımı', value: '30 dakika', key: 'sessionTimeout' }
      ]
    },
    { 
      title: 'Veritabanı', 
      icon: Database, 
      gradient: 'from-purple-400 to-purple-600',
      bgGradient: 'from-purple-50 to-purple-100',
      description: 'Veri yönetimi ve yedekleme',
      items: [
        { label: 'Otomatik Yedekleme', value: settings.autoBackup, key: 'autoBackup' },
        { label: 'Yedekleme Sıklığı', value: 'Günlük', key: 'backupFrequency' },
        { label: 'Veri Saklama', value: '90 gün', key: 'dataRetention' }
      ]
    },
    { 
      title: 'Görünüm', 
      icon: Palette, 
      gradient: 'from-pink-400 to-pink-600',
      bgGradient: 'from-pink-50 to-pink-100',
      description: 'Tema ve arayüz ayarları',
      items: [
        { label: 'Karanlık Mod', value: settings.darkMode, key: 'darkMode' },
        { label: 'Animasyonlar', value: true, key: 'animations' },
        { label: 'Kompakt Görünüm', value: false, key: 'compactView' }
      ]
    },
  ]

  const monetizationSettings = [
    { 
      label: 'Premium Fiyat', 
      value: `₺${settings.premiumPrice}`, 
      icon: Zap,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-50'
    },
    { 
      label: 'Günlük Yorum Limiti', 
      value: settings.dailyLimit, 
      icon: Lock,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50'
    },
    { 
      label: 'Yükselen Burç Limiti', 
      value: settings.risingSignLimit, 
      icon: Lock,
      color: 'text-indigo-600',
      bgColor: 'bg-indigo-50'
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
          Ayarlar
        </h1>
        <p className="text-gray-600 mt-1">Uygulama ayarlarını yönetin ve özelleştirin</p>
      </div>

      {/* Monetization Settings */}
      <div className="card bg-gradient-to-r from-yellow-400 via-orange-400 to-red-400 text-white border-0">
        <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
          <Zap className="w-5 h-5" />
          Para Tuzakları Ayarları
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {monetizationSettings.map((setting, index) => (
            <div key={index} className="bg-white/20 backdrop-blur-sm rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <setting.icon className="w-4 h-4" />
                <p className="text-sm text-white/90">{setting.label}</p>
              </div>
              <p className="text-2xl font-bold">{setting.value}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Settings Categories */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {settingsCategories.map((category, index) => (
          <div key={index} className={`card bg-gradient-to-br ${category.bgGradient} border-0 hover:shadow-xl transition-all`}>
            <div className="flex items-start gap-4">
              <div className={`p-3 bg-gradient-to-br ${category.gradient} rounded-xl shadow-lg`}>
                <category.icon className="w-6 h-6 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-gray-900">{category.title}</h3>
                <p className="text-sm text-gray-600 mt-1">{category.description}</p>
                
                <div className="mt-4 space-y-3">
                  {category.items.map((item, itemIndex) => (
                    <div key={itemIndex} className="flex items-center justify-between">
                      <span className="text-sm text-gray-700">{item.label}</span>
                      {typeof item.value === 'boolean' ? (
                        <div className={`w-10 h-6 rounded-full transition-colors ${
                          item.value ? 'bg-green-500' : 'bg-gray-300'
                        } relative cursor-pointer`}>
                          <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                            item.value ? 'translate-x-4' : 'translate-x-0'
                          }`}></div>
                        </div>
                      ) : (
                        <span className="text-sm font-medium text-gray-900 bg-white px-2 py-1 rounded">
                          {item.value}
                        </span>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* App Info */}
      <div className="card bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white border-0">
        <div className="flex items-start gap-4">
          <div className="p-3 bg-white/20 rounded-lg backdrop-blur-sm">
            <Smartphone className="w-6 h-6" />
          </div>
          <div className="flex-1">
            <h3 className="text-lg font-semibold">Uygulama Bilgileri</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4">
              <div>
                <p className="text-xs text-white/70">Versiyon</p>
                <p className="text-sm font-semibold mt-1">1.0.0</p>
              </div>
              <div>
                <p className="text-xs text-white/70">Platform</p>
                <p className="text-sm font-semibold mt-1">Flutter</p>
              </div>
              <div>
                <p className="text-xs text-white/70">Backend</p>
                <p className="text-sm font-semibold mt-1">Firebase</p>
              </div>
              <div>
                <p className="text-xs text-white/70">AI Engine</p>
                <p className="text-sm font-semibold mt-1">Gemini</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <button className="card hover:shadow-lg transition-all text-left bg-gradient-to-br from-blue-50 to-blue-100 border-blue-200">
          <Globe className="w-8 h-8 text-blue-600 mb-2" />
          <h4 className="font-semibold text-gray-900">Veritabanını Temizle</h4>
          <p className="text-sm text-gray-600 mt-1">Eski verileri temizle</p>
        </button>
        
        <button className="card hover:shadow-lg transition-all text-left bg-gradient-to-br from-green-50 to-green-100 border-green-200">
          <Database className="w-8 h-8 text-green-600 mb-2" />
          <h4 className="font-semibold text-gray-900">Yedek Al</h4>
          <p className="text-sm text-gray-600 mt-1">Manuel yedekleme başlat</p>
        </button>
        
        <button className="card hover:shadow-lg transition-all text-left bg-gradient-to-br from-red-50 to-red-100 border-red-200">
          <Shield className="w-8 h-8 text-red-600 mb-2" />
          <h4 className="font-semibold text-gray-900">Güvenlik Taraması</h4>
          <p className="text-sm text-gray-600 mt-1">Sistem kontrolü yap</p>
        </button>
      </div>
    </div>
  )
}
