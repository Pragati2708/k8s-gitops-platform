import { useState } from "react";
import "./App.css";

function App() {

  const [response, setResponse] = useState("");

  const callApi = async (url) => {

    try {

      const res = await fetch(url);

      const data = await res.json();

      setResponse(
        JSON.stringify(data, null, 2)
      );

    } catch (error) {

      setResponse(
        "API Error: " + error.message
      );
    }
  };


  return (

    <div className="container">

      <h1>🚀 Cloud Banking Platform</h1>

      <p className="subtitle">
        Production DevOps Platform running on AWS EKS
      </p>


      <div className="architecture">

        <span>Terraform</span>
        →
        <span>EKS</span>
        →
        <span>ArgoCD</span>
        →
        <span>Kubernetes</span>

      </div>


      <div className="cards">


        <div className="card">

          <h2>Legacy Service</h2>

          <p>Core Banking API</p>

          <button
            onClick={() =>
              callApi("/api/legacy/balance/1001")
            }
          >
            Check Balance
          </button>

        </div>



        <div className="card">

          <h2>Transaction Service</h2>

          <p>Transaction API</p>

          <button
            onClick={() =>
              callApi("/api/transactions/health")
            }
          >
            Check Transaction
          </button>

        </div>



        <div className="card">

          <h2>Notification Service</h2>

          <p>Notification API</p>

          <button
            onClick={() =>
              callApi("/api/notifications/health")
            }
          >
            Check Notification
          </button>

        </div>


      </div>


      <h2>API Response</h2>

      <pre>
        {response}
      </pre>



      <div className="footer">

        GitHub Actions | ECR | Prometheus | Grafana | Slack Alerts

      </div>


    </div>

  );
}


export default App;