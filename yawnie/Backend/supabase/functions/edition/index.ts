import { runEdition } from "./runner.ts";

// POST /edition  body: { deviceContext }  ->  { day, results }
Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response("POST only", { status: 405 });
  const { deviceContext } = await req.json();
  return Response.json(await runEdition(deviceContext));
});
