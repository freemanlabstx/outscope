import React from "react";
import { createRoot } from "react-dom/client";
import App from "./ai/App.jsx";

const root = createRoot(document.getElementById("ai-app"));
root.render(<App />);
