import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const text = body.text ?? body.note;

    if (!text || typeof text !== "string" || text.trim().length < 5) {
      return new Response(
        JSON.stringify({ error: "النص غير صالح" }),
        { status: 400, headers: corsHeaders }
      );
    }

    const prompt = `
صحح الأخطاء الإملائية والنحوية في النص العربي التالي،
ثم أعد صياغته بأسلوب واضح وسلس مع ترتيب الأفكار،
مع الحفاظ على نفس المعنى:

النص:
"${text}"

النص المحسن:
`;

    const hfResponse = await fetch(
      "https://router.huggingface.co/hf-inference/models/UBC-NLP/AraT5v2-base-1024",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${Deno.env.get("HF_API_KEY")}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          inputs: prompt,
          parameters: {
            max_new_tokens: 200,
            temperature: 0.7,
            top_p: 0.95,
            repetition_penalty: 1.3,
          },
        }),
      }
    );

    const data = await hfResponse.json();

    const generated =
      data?.[0]?.generated_text
        ?.replace(prompt, "")
        .trim() ?? text;

    return new Response(
      JSON.stringify({
        success: true,
        result: generated,
        original: text,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
        status: 200,
      }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({
        success: false,
        error: e.message ?? "Server error",
      }),
      {
        headers: corsHeaders,
        status: 500,
      }
    );
  }
});
