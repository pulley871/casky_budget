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
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
//BROKEN CODE NEED TO FIX
// import "phoenix_html";

// // Establish Phoenix Socket and LiveView configuration.
// import { Socket } from "phoenix";
// import { LiveSocket } from "phoenix_live_view";
// import topbar from "../vendor/topbar";
// import Chart from "chart.js";

// let hooks = {};

// // Doughnut Chart Hook
// hooks.ChartJSDoughnut = {
//   dataset() {
//     // Safely parse dataset points
//     try {
//       return JSON.parse(this.el.dataset.points);
//     } catch (error) {
//       console.error("Error parsing dataset points for doughnut chart:", error);
//       return [];
//     }
//   },
//   mounted() {
//     try {
//       const ctx = this.el;
//       const config = {
//         type: "doughnut",
//         data: {
//           labels: ["Remaining", "Spent", "Pending"],
//           datasets: [
//             {
//               data: this.dataset(),
//               backgroundColor: [
//                 "rgb(75, 192, 192)",
//                 "rgb(255, 99, 132)",
//                 "rgb(255, 255, 0)",
//               ],
//               hoverOffset: 4,
//             },
//           ],
//         },
//       };
//       new Chart(ctx, config);
//     } catch (error) {
//       console.error("Error initializing doughnut chart:", error);
//     }
//   },
// };

// // Bar Chart Hook
// hooks.ChartJSBarChart = {
//   dataset() {
//     // Safely parse dataset points
//     try {
//       return JSON.parse(this.el.dataset.points);
//     } catch (error) {
//       console.error("Error parsing dataset points for bar chart:", error);
//       return [];
//     }
//   },
//   mounted() {
//     try {
//       const ctx = this.el;
//       const data = {
//         labels: ["1st Quarter", "2nd Quarter", "3rd Quarter", "4th Quarter"],
//         datasets: [
//           {
//             data: this.dataset(),
//             label: "Quarterly breakdown",
//             backgroundColor: "rgba(54, 162, 235, 0.6)",
//             borderColor: "rgba(54, 162, 235, 1)",
//             borderWidth: 1,
//           },
//         ],
//       };
//       const config = {
//         type: "bar",
//         data: data,
//         options: {
//           scales: {
//             y: {
//               beginAtZero: true,
//               ticks: {
//                 stepSize: 100,
//               },
//             },
//           },
//         },
//       };
//       new Chart(ctx, config);
//     } catch (error) {
//       console.error("Error initializing bar chart:", error);
//     }
//   },
// };

// let csrfToken = document
//   .querySelector("meta[name='csrf-token']")
//   .getAttribute("content");

// let liveSocket = new LiveSocket("/live", Socket, {
//   longPollFallbackMs: 2500,
//   params: { _csrf_token: csrfToken },
//   hooks: hooks,
// });

// // Show progress bar on live navigation and form submits
// topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
// window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
// window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// // Connect if there are any LiveViews on the page
// liveSocket.connect();

// // Expose liveSocket on window for web console debug logs and latency simulation:
// // >> liveSocket.enableDebug()
// // >> liveSocket.enableLatencySim(1000)  // Enabled for duration of browser session
// // >> liveSocket.disableLatencySim()
// window.liveSocket = liveSocket;
