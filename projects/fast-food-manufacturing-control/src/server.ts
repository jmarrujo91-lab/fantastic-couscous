import express from "express";

const app = express();
const port = Number(process.env.PORT ?? 3000);

app.disable("x-powered-by");
app.use(express.json({ limit: "32kb", strict: true }));

app.get("/health", (_request, response) => {
  response.status(200).json({ status: "ok", mode: "development-scaffold" });
});

// No business routes are exposed until authentication, authorization,
// site scoping, audit persistence, and transactional hold enforcement exist.
app.listen(port, () => {
  process.stdout.write(`Development scaffold listening on port ${port}\n`);
});
