import "./App.css";

function App() {

  const services = [
    {
      name: "Legacy Service",
      status: "Healthy",
      replicas: "2/2",
      tech: "Java API"
    },
    {
      name: "Transaction Service",
      status: "Healthy",
      replicas: "2/2",
      tech: "REST API"
    },
    {
      name: "Notification Service",
      status: "Healthy",
      replicas: "2/2",
      tech: "Event Service"
    }
  ];


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

        {services.map((service) => (

          <div className="card">

            <h2>{service.name}</h2>

            <p>🟢 {service.status}</p>

            <p>Replicas: {service.replicas}</p>

            <p>{service.tech}</p>

          </div>

        ))}

      </div>


      <div className="footer">

        GitHub Actions | ECR | Prometheus | Grafana | Slack Alerts

      </div>


    </div>

  );
}

export default App;