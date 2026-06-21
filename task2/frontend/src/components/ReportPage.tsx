import React, { useState } from 'react';
import { useKeycloak } from '@react-keycloak/web';

// 1. Убеждаемся, что интерфейс описывает абсолютно все поля из ClickHouse
interface TelemetryReport {
  login: string;
  first_name: string;
  last_name: string;
  e_mail: string;
  id_device: string;
  model: string;
  timestamp: string;
  battery_level: number;
}

const ReportPage: React.FC = () => {
  const { keycloak, initialized } = useKeycloak();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [reportData, setReportData] = useState<TelemetryReport[]>([]);

  const downloadReport = async () => {
    if (!keycloak?.token) {
      setError('Not authenticated');
      return;
    }

    // Достаем логин из токена Keycloak
    const userLogin = keycloak.idTokenParsed?.preferred_username;
    
    if (!userLogin) {
      setError('Could not find user login in token');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const url = `${process.env.REACT_APP_API_URL}/reports?login=${encodeURIComponent(userLogin)}`;

      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${keycloak.token}`,
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`Server error: ${response.status} ${response.statusText}`);
      }

      const data: TelemetryReport[] = await response.json();
      setReportData(data);

    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  if (!initialized) {
    return <div>Loading...</div>;
  }

  if (!keycloak.authenticated) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
        <button
          onClick={() => keycloak.login()}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
          Login
        </button>
      </div>
    );
  }

  // Берем первого попавшегося клиента из массива для отображения общей карточки пользователя
  const clientInfo = reportData.length > 0 ? reportData[0] : null;

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100 p-6">
      <div className="w-full max-w-6xl p-8 bg-white rounded-lg shadow-md">
        <h1 className="text-2xl font-bold mb-6 text-center text-gray-800">Analytics & Telemetry Dashboard</h1>

        <div className="flex justify-center mb-6">
          <button
            onClick={downloadReport}
            disabled={loading}
            className={`px-6 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors ${
              loading ? 'opacity-50 cursor-not-allowed' : ''
            }`}
          >
            {loading ? 'Generating Report...' : 'Load Full Report'}
          </button>
        </div>

        {error && (
          <div className="mt-4 p-4 bg-red-100 text-red-700 rounded text-center">
            {error}
          </div>
        )}

        {/* БЛОК ПАНЕЛИ ИНФОРМАЦИИ О КЛИЕНТЕ */}
        {clientInfo && (
          <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg grid grid-cols-2 md:grid-cols-4 gap-4 text-sm text-gray-700">
            <div>
              <span className="block text-xs font-semibold uppercase text-gray-400">User Login</span>
              <span className="font-mono text-gray-900 font-bold">{clientInfo.login}</span>
            </div>
            <div>
              <span className="block text-xs font-semibold uppercase text-gray-400">Full Name</span>
              <span className="text-gray-900">{clientInfo.first_name} {clientInfo.last_name}</span>
            </div>
            <div>
              <span className="block text-xs font-semibold uppercase text-gray-400">Contact Email</span>
              <span className="text-gray-900 font-medium">{clientInfo.e_mail}</span>
            </div>
            <div>
              <span className="block text-xs font-semibold uppercase text-gray-400">Total Records Found</span>
              <span className="text-gray-900 font-bold">{reportData.length}</span>
            </div>
          </div>
        )}

        {/* ШИРОКАЯ ТАБЛИЦА С ПОЛНЫМИ ДАННЫМИ */}
        {reportData.length > 0 && (
          <div className="mt-4 overflow-x-auto">
            <table className="min-w-full bg-white border border-gray-200 rounded-lg overflow-hidden shadow-sm">
              <thead className="bg-gray-100 text-gray-700 uppercase text-xs font-bold tracking-wider">
                <tr>
                  <th className="py-3 px-4 text-left border-b">Login</th>
                  <th className="py-3 px-4 text-left border-b">First Name</th>
                  <th className="py-3 px-4 text-left border-b">Last Name</th>
                  <th className="py-3 px-4 text-left border-b">Email</th>
                  <th className="py-3 px-4 text-left border-b">Device ID</th>
                  <th className="py-3 px-4 text-left border-b">Model</th>
                  <th className="py-3 px-4 text-left border-b">Timestamp</th>
                  <th className="py-3 px-4 text-center border-b">Battery</th>
                </tr>
              </thead>
              <tbody className="text-gray-600 text-sm divide-y divide-gray-100">
                {reportData.map((row, index) => (
                  <tr key={index} className="hover:bg-gray-50 transition-colors">
                    <td className="py-3 px-4 font-mono text-xs font-semibold text-gray-900">{row.login}</td>
                    <td className="py-3 px-4">{row.first_name}</td>
                    <td className="py-3 px-4">{row.last_name}</td>
                    <td className="py-3 px-4 text-xs font-medium">{row.e_mail}</td>
                    <td className="py-3 px-4 font-mono text-xs text-gray-400">{row.id_device}</td>
                    <td className="py-3 px-4 font-medium text-blue-600">{row.model}</td>
                    <td className="py-3 px-4 text-xs text-gray-500 whitespace-nowrap">{row.timestamp}</td>
                    <td className="py-3 px-4 text-center">
                      <span className={`inline-block w-14 py-1 rounded text-xs font-bold ${
                        row.battery_level > 50 ? 'bg-green-100 text-green-800' :
                        row.battery_level > 20 ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {row.battery_level}%
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {!loading && reportData.length === 0 && !error && (
          <p className="text-center text-gray-500 mt-4">No report data loaded yet.</p>
        )}
      </div>
    </div>
  );
};

export default ReportPage;

