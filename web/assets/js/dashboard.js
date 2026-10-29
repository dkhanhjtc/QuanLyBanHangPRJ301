/**
 * KIOTFLOW - Dashboard Analytics & Chart.js Config
 */

document.addEventListener('DOMContentLoaded', function() {
  const ctx = document.getElementById('revenueChart');
  if (!ctx) return;

  // Chart data matching mockup
  const labels = ['21/10', '22/10', '23/10', '24/10', '25/10', '26/10', '27/10'];
  const dataValues = [1.200, 1.650, 1.400, 1.900, 2.100, 1.550, 1.254];

  // Highlights today (27/10) in vibrant primary blue #2563eb, other days in soft light blue #bfdbfe
  const backgroundColors = [
    '#bfdbfe',
    '#bfdbfe',
    '#bfdbfe',
    '#bfdbfe',
    '#bfdbfe',
    '#bfdbfe',
    '#2563eb'
  ];

  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Doanh thu (triệu đồng)',
        data: dataValues,
        backgroundColor: backgroundColors,
        borderRadius: 4,
        borderSkipped: false,
        barPercentage: 0.72
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          backgroundColor: '#0f172a',
          titleFont: { family: 'Inter', size: 12 },
          bodyFont: { family: 'Inter', size: 13, weight: 'bold' },
          padding: 10,
          cornerRadius: 8,
          callbacks: {
            label: function(context) {
              return context.parsed.y.toFixed(3) + ' triệu đồng';
            }
          }
        }
      },
      scales: {
        x: {
          grid: {
            display: false
          },
          ticks: {
            font: { family: 'Inter', size: 11 },
            color: '#64748b'
          }
        },
        y: {
          min: 0,
          max: 2.5,
          ticks: {
            stepSize: 0.5,
            font: { family: 'Inter', size: 11 },
            color: '#64748b',
            callback: function(val) {
              return val.toString().replace('.', ',');
            }
          },
          grid: {
            color: '#f1f5f9'
          },
          border: {
            dash: [4, 4]
          }
        }
      }
    }
  });
});

