import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";
import OpenAI from "openai";

dotenv.config();

// 🗄️ Connect to Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// 🤖 Connect to OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// 🧠 NLP Processor with batch
async function processMessages(batchSize = 10) {
  console.log("🔵 بدء تحليل NLP...");

  // 1️⃣ Fetch raw telegram messages
  const { data: rawMessages, error } = await supabase
    .from("telegram_raw_messages")
    .select("*")
    .order("id", { ascending: true });

  if (error) {
    console.error("❌ خطأ في جلب الرسائل:", error);
    return;
  }

  if (!rawMessages || rawMessages.length === 0) {
    console.log("ℹ️ لا يوجد رسائل جديدة.");
    return;
  }

  console.log(`📩 عدد الرسائل: ${rawMessages.length}`);

  // 2️⃣ Process messages in batches
  for (let i = 0; i < rawMessages.length; i += batchSize) {
    const batch = rawMessages.slice(i, i + batchSize);
    console.log(`⏳ معالجة الدفعة من ${i + 1} إلى ${i + batch.length}`);

    for (const msg of batch) {
      try {
        const prompt = `
حلّل الرسالة التالية الخاصة بوضع الطرق في فلسطين.
أرجع فقط JSON بالشكل التالي:

{
  "status": "",
  "location": "",
  "confidence": 0,
  "reasoning": "",
  "detected_terms": []
}

النص:
"""${msg.message}"""
`;

        const completion = await openai.chat.completions.create({
          model: "gpt-3.5-turbo", // يمكن تغييره لـ gpt-4o-mini
          messages: [{ role: "user", content: prompt }],
          temperature: 0.2,
        });

        const aiResponse = completion.choices[0].message.content;
        console.log("🧾 الناتج:", aiResponse);

        // Parse JSON
        let result;
        try {
          result = JSON.parse(aiResponse);
        } catch {
          console.error("⚠️ JSON غير صالح! تخطي الرسالة.");
          continue;
        }

        // Save to processed table
        const { error: saveError } = await supabase
          .from("telegram_processed_messages")
          .insert({
            raw_id: msg.id,
            message: msg.message,
            status: result.status,
            location: result.location,
            confidence: result.confidence,
            reasoning: result.reasoning,
            detected_terms: result.detected_terms,
          });

        if (saveError) {
          console.error("❌ خطأ في حفظ التحليل:", saveError);
        } else {
          console.log(`✅ تم تحليل الرسالة ${msg.id} بنجاح.`);
        }
      } catch (err) {
        console.error("⚠️ خطأ أثناء تحليل الرسالة:", err);
      }
    }

    // 3️⃣ انتظر 1.5 ثانية بين كل دفعة
    await new Promise((res) => setTimeout(res, 1500));
  }

  console.log("🏁 انتهى التحليل.");
}

// 🚀 Run
processMessages();
