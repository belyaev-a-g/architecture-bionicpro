import React, { useState } from 'react';
import { useKeycloak } from '@react-keycloak/web';

// 1. Описываем интерфейс данных, которые возвращает наш FastAPI из ClickHouse
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
  
  //# 2. Добавляем состояние для хранения массива данных отчета
  const [reportData, setReportData] = useState<TelemetryReport[]>([]);

  const downloadReport = async () => {
    if (!keycloak?.token) {
      setError('Not authenticated');
      return;
    }

    //# 3. Достаем логин текущего пользователя из JWT-токена Keycloak
    //# По умолчанию Keycloak хранит логин в поле 'preferred_username'
    const userLogin = keycloak.idTokenParsed?.preferred_username;
    
    if (!userLogin) {
      setError('Could not find user login in token');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      //# 4. Формируем URL с обязательным query-параметром ?login=...
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

      //# 5. Парсим JSON и сохраняем его в состояние
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

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100 p-6">
      <div className="w-full max-w-4xl p-8 bg-white rounded-lg shadow-md">
        <h1 className="text-2xl font-bold mb-6 text-center">Usage Reports</h1>

        <div className="flex justify-center mb-6">
          <button
            onClick={downloadReport}
            disabled={loading}
            className={`px-6 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors ${
              loading ? 'opacity-50 cursor-not-allowed' : ''
            }`}
          >
            {loading ? 'Generating Report...' : 'Load Report'}
          </button>
        </div>

        {error && (
          <div className="mt-4 p-4 bg-red-100 text-red-700 rounded text-center">
            {error}
          </div>
        )}

        {reportData.length > 0 && (
          <div className="mt-6 overflow-x-auto">
            <h2 className="text-lg font-semibold mb-3 text-gray-700">
              Telemetry History for: <span className="font-bold text-blue-600">{reportData[0].login}</span>
            </h2>
            <table className="min-w-full bg-white border border-gray-200 rounded-lg overflow-hidden">
              <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                <tr>
                  <th className="py-3 px-4 text-left border-b">Device ID</th>
                  <th className="py-3 px-4 text-left border-b">Model</th>
                  <th className="py-3 px-4 text-left border-b">Timestamp</th>
                  <th className="py-3 px-4 text-center border-b">Battery Level</th>
                </tr>
              </thead>
              <tbody className="text-gray-600 text-sm">
                {reportData.map((row, index) => (
                  <tr key={index} className="hover:bg-gray-50 border-b">
                    <td className="py-3 px-4 font-mono text-xs">{row.id_device}</td>
                    <td className="py-3 px-4">{row.model}</td>
                    <td className="py-3 px-4">{row.timestamp}</td>
                    <td className="py-3 px-4 text-center">
                      <span className={`px-2 py-1 rounded text-xs font-bold ${
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
          <p className="text-center text-gray-500 mt-4">No telemetry data found.</p>
        )}
      </div>
    </div>
  );
};

export default ReportPage;

