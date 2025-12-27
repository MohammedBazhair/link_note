import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  const { prompt } = await req.json();

  const apiUrl = Deno.env.get("AI_API_URL")!;
  const apiKey = Deno.env.get("AI_API_KEY")!;

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "accept": "application/json",
      "x-api-market-key": apiKey,
    },
    body: JSON.stringify({
      model: "gpt-4-1-nano",
      messages: [
        { role: "user", content: prompt }
      ]
    }),
  });

  const data = await response.json();
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" },
  });
});
