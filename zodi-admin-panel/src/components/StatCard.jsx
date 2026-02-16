import { TrendingUp, TrendingDown } from 'lucide-react'

export default function StatCard({ title, value, change, icon: Icon, trend = 'up' }) {
  const isPositive = trend === 'up'

  return (
    <div className="card">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">{value}</p>
          {change && (
            <div className="mt-2 flex items-center gap-1">
              {isPositive ? (
                <TrendingUp className="w-4 h-4 text-green-600" />
              ) : (
                <TrendingDown className="w-4 h-4 text-red-600" />
              )}
              <span className={`text-sm font-medium ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
                {change}
              </span>
              <span className="text-sm text-gray-500">son 30 gün</span>
            </div>
          )}
        </div>
        {Icon && (
          <div className="p-3 bg-primary-50 rounded-lg">
            <Icon className="w-6 h-6 text-primary-600" />
          </div>
        )}
      </div>
    </div>
  )
}
