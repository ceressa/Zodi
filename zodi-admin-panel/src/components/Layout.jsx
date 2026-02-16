import { Outlet, NavLink } from 'react-router-dom'
import { 
  LayoutDashboard, Users, BarChart3, FileText, 
  DollarSign, Settings, Sparkles, Activity 
} from 'lucide-react'

const navigation = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Kullanıcılar', href: '/users', icon: Users },
  { name: 'Aktivite Logları', href: '/activity-logs', icon: Activity },
  { name: 'Analitik', href: '/analytics', icon: BarChart3 },
  { name: 'İçerik', href: '/content', icon: FileText },
  { name: 'Gelir', href: '/revenue', icon: DollarSign },
  { name: 'Ayarlar', href: '/settings', icon: Settings },
]

export default function Layout() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="fixed inset-y-0 left-0 w-64 bg-gradient-to-b from-purple-900 via-purple-800 to-pink-900 text-white shadow-2xl">
        <div className="flex items-center gap-3 p-6 border-b border-white/10">
          <img 
            src="/zodi_logo.webp" 
            alt="Zodi Logo" 
            className="w-12 h-12 rounded-xl shadow-lg"
          />
          <div>
            <h1 className="text-xl font-bold bg-gradient-to-r from-yellow-300 to-pink-300 bg-clip-text text-transparent">
              Zodi
            </h1>
            <p className="text-xs text-purple-300">Admin Panel</p>
          </div>
        </div>

        <nav className="p-4 space-y-1">
          {navigation.map((item) => (
            <NavLink
              key={item.name}
              to={item.href}
              end={item.href === '/'}
              className={({ isActive }) =>
                `flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                  isActive
                    ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-lg scale-105'
                    : 'text-purple-200 hover:bg-white/10 hover:text-white hover:scale-102'
                }`
              }
            >
              <item.icon className="w-5 h-5" />
              <span className="font-medium">{item.name}</span>
            </NavLink>
          ))}
        </nav>

        {/* Footer */}
        <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-white/10">
          <div className="text-xs text-purple-300 text-center">
            <p>Zodi Admin v1.0</p>
            <p className="text-purple-400 mt-1">© 2026 Zodi</p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="ml-64">
        <div className="p-8">
          <Outlet />
        </div>
      </div>
    </div>
  )
}
