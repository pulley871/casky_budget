// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
// import "phoenix_html"
// // Establish Phoenix Socket and LiveView configuration.
// import {Socket} from "phoenix"
// import {LiveSocket} from "phoenix_live_view"
// import topbar from "../vendor/topbar"

// let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
// let liveSocket = new LiveSocket("/live", Socket, {
//   longPollFallbackMs: 2500,
//   params: {_csrf_token: csrfToken}
// })

// // Show progress bar on live navigation and form submits
// topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
// window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
// window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// // connect if there are any LiveViews on the page
// liveSocket.connect()

// // expose liveSocket on window for web console debug logs and latency simulation:
// // >> liveSocket.enableDebug()
// // >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// // >> liveSocket.disableLatencySim()
// window.liveSocket = liveSocket


// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
//BROKEN CODE NEED TO FIX
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { 
  Chart, 
  DoughnutController, 
  BarController,
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement, 
  Tooltip, 
  Legend 
} from 'chart.js';

// Register all required components
Chart.register(
  DoughnutController,
  BarController,
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  Tooltip,
  Legend
);

let hooks = {};

// Utility function to safely parse JSON
const safeJSONParse = (str, fallback = []) => {
  try {
    return JSON.parse(str);
  } catch (error) {
    console.error("JSON parsing error:", error);
    return fallback;
  }
};

// Doughnut Chart Hook
hooks.ChartJSDoughnut = {
  mounted() {
    if (!this.el) {
      console.error("Chart element not found");
      return;
    }

    const points = safeJSONParse(this.el.dataset.points, [0, 0, 0]);

    if (this.chart) {
      this.chart.destroy();
    }

    try {
      const ctx = this.el.getContext('2d');
      this.chart = new Chart(ctx, {
        type: 'doughnut',
        data: {
          labels: ['Remaining', 'Spent', 'Pending'],
          datasets: [{
            data: points,
            backgroundColor: [
              'rgb(75, 192, 192)',
              'rgb(255, 99, 132)',
              'rgb(255, 255, 0)'
            ],
            hoverOffset: 4
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false
        }
      });
    } catch (error) {
      console.error("Error creating doughnut chart:", error);
    }
  },

  destroyed() {
    if (this.chart) {
      this.chart.destroy();
    }
  },

  updated() {
    const newPoints = safeJSONParse(this.el.dataset.points, [0, 0, 0]);
    if (this.chart) {
      this.chart.data.datasets[0].data = newPoints;
      this.chart.update();
    }
  }
};

// Bar Chart Hook
hooks.ChartJSBarChart = {
  mounted() {
    if (!this.el) {
      console.error("Chart element not found");
      return;
    }

    const points = safeJSONParse(this.el.dataset.points, [0, 0, 0, 0]);

    if (this.chart) {
      this.chart.destroy();
    }

    try {
      const ctx = this.el.getContext('2d');
      this.chart = new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['1st Quarter', '2nd Quarter', '3rd Quarter', '4th Quarter'],
          datasets: [{
            label: 'Quarterly breakdown',
            data: points,
            backgroundColor: 'rgba(54, 162, 235, 0.6)',
            borderColor: 'rgba(54, 162, 235, 1)',
            borderWidth: 1
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                stepSize: 100
              }
            }
          }
        }
      });
    } catch (error) {
      console.error("Error creating bar chart:", error);
    }
  },

  destroyed() {
    if (this.chart) {
      this.chart.destroy();
    }
  },

  updated() {
    const newPoints = safeJSONParse(this.el.dataset.points, [0, 0, 0, 0]);
    if (this.chart) {
      this.chart.data.datasets[0].data = newPoints;
      this.chart.update();
    }
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: hooks
});

topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", info => topbar.show(300));
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

liveSocket.connect();
window.liveSocket = liveSocket;
