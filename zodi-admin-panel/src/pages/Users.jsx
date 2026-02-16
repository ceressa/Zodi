import { useState, useEffect } from 'react'
import { Search, Filter, Download, Crown, Calendar, X, Star, Sparkles, Moon, TrendingUp } from 'lucide-react'
import { db } from '../firebase'
import { collection, getDocs, query, orderBy, limit } from 'firebase/firestore'
import { format } from 'date-fns'
import { tr } from 'date-fns/locale'

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

export default function Users() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterType, setFilterType] = useState('all') // all, premium, free
  const [selectedUser, setSelectedUser] = useState(null)

  useEffect(() => {
    loadUsers()
  }, [])

  const loadUsers = async () => {
    try {
      // Tüm kullanıcıları çek
      const usersSnapshot = await getDocs(collection(db, 'users'))
      
      const usersData = usersSnapshot.docs
        .map(doc => ({
          id: doc.id,
          ...doc.data()
        }))
        .sort((a, b) => {
          // createdAt'e göre sırala (en yeni önce)
          const dateA = toDate(a.createdAt)
          const dateB = toDate(b.createdAt)
          if (!dateA && !dateB) return 0
          if (!dateA) return 1
          if (!dateB) return -1
          return dateB - dateA
        })
        .slice(0, 100) // İlk 100'ü al
      
      setUsers(usersData)
    } catch (error) {
      console.error('Kullanıcılar yüklenemedi:', error)
      setUsers([])
    } finally {
      setLoading(false)
    }
  }

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.email?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesFilter = filterType === 'all' ||
                         (filterType === 'premium' && user.isPremium) ||
                         (filterType === 'free' && !user.isPremium)
    return matchesSearch && matchesFilter
  })

  const exportToCSV = () => {
    const csv = [
      ['İsim', 'E-posta', 'Burç', 'Premium', 'Kayıt Tarihi'],
      ...filteredUsers.map(user => {
        const createdDate = toDate(user.createdAt)
        return [
          user.name || '-',
          user.email || '-',
          user.zodiacSign || '-',
          user.isPremium ? 'Evet' : 'Hayır',
          createdDate ? format(createdDate, 'dd/MM/yyyy', { locale: tr }) : '-'
        ]
      })
    ].map(row => row.join(',')).join('\n')

    const blob = new Blob([csv], { type: 'text/csv' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `zodi-users-${format(new Date(), 'yyyy-MM-dd')}.csv`
    a.click()
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
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Kullanıcılar</h1>
          <p className="text-gray-600 mt-1">{users.length} toplam kullanıcı</p>
        </div>
        <button
          onClick={exportToCSV}
          className="btn-primary flex items-center gap-2"
        >
          <Download className="w-4 h-4" />
          CSV İndir
        </button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="İsim veya e-posta ile ara..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setFilterType('all')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                filterType === 'all'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Tümü
            </button>
            <button
              onClick={() => setFilterType('premium')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                filterType === 'premium'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Premium
            </button>
            <button
              onClick={() => setFilterType('free')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                filterType === 'free'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Ücretsiz
            </button>
          </div>
        </div>
      </div>

      {/* Users Table */}
      <div className="card overflow-hidden p-0">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Kullanıcı
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Burç
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Durum
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Kayıt Tarihi
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Son Aktivite
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredUsers.map((user) => (
                <tr key={user.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10 bg-gradient-to-br from-primary-400 to-primary-600 rounded-full flex items-center justify-center text-white font-semibold">
                        {user.name?.charAt(0) || '?'}
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900 flex items-center gap-2">
                          {user.name || 'İsimsiz'}
                          {user.isPremium && <Crown className="w-4 h-4 text-yellow-500" />}
                        </div>
                        <div className="text-sm text-gray-500">{user.email}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-2xl">{user.zodiacSign || '—'}</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      user.isPremium
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {user.isPremium ? 'Premium' : 'Ücretsiz'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div className="flex flex-col">
                      <span>{user.createdAt ? format(toDate(user.createdAt), 'dd MMM yyyy HH:mm', { locale: tr }) : '-'}</span>
                      <span className="text-xs text-gray-400">
                        {user.createdAt ? getTimeAgo(toDate(user.createdAt)) : '-'}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {user.lastActive ? format(toDate(user.lastActive), 'dd MMM yyyy', { locale: tr }) : '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
