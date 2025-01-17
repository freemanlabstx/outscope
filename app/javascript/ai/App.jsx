import React, { useEffect, useState } from "react";
import { useChat } from "ai/react";

const defaultHelpMessage = "Ask the AI anything about your report.";

const App = () => {
  const [apiToken, setApiToken] = useState("");
  const [initialMessages, setInitialMessages] = useState([]);

  useEffect(() => {
    const configText = document.getElementById("ai-config").innerText;
    const config = JSON.parse(configText);
    if (config.api_token) {
      setApiToken(config.api_token);
    }

    // get initial messages
  }, []);

  const { messages, input, handleInputChange, handleSubmit } = useChat({
    headers: {
      "Authorization": `Bearer ${apiToken}`,
    },
    initialMessages: [{ content: defaultHelpMessage }],
  });

  return (
    <div class="space-y-4">
      <div>
        {messages.map((m) => (
          <div key={m.id}>
            <span class="mb-1 text-sm dark:text-gray-100">
              {m.role === "user" ? "User" : "AI"}
            </span>
            <div
              className={[
                "rounded",
                "p-4",
                m.role === "user" ? "bg-blue-800 text-white" : "bg-gray-800",
              ].join(" ")}
            >
              {m.content}
            </div>
          </div>
        ))}
      </div>

      <form onSubmit={handleSubmit}>
        <input
          className="form-control"
          placeholder="Ask the AI anything"
          value={input}
          onChange={handleInputChange}
        />
      </form>
    </div>
  );
};

export default App;
