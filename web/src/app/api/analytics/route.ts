import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  const body = await request.json();
  console.log("Analytics data received:", body);

  // If this is a game_started event, also send to pingr
  if (body.event === "game_started") {
    try {
      const pingr_token = process.env.PINGR_API_TOKEN;
      if (!pingr_token) {
        console.warn(
          "PINGR_API_TOKEN not configured - skipping pingr notification"
        );
      } else {
        const pingrResponse = await fetch(
          "https://pingr-dev.vercel.app/api/messages",
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${pingr_token}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              title: `Game Started - ${body.artist_name || "Unknown Artist"}`,
              body: `User started a new Heardle game with artist: ${body.artist_name || "Unknown"}`,
              tags: ["heardle", "game_started"],
            }),
          }
        );

        if (!pingrResponse.ok) {
          console.error("Failed to send to pingr:", pingrResponse.statusText);
        } else {
          console.log("Successfully sent game start notification to pingr");
        }
      }
    } catch (error) {
      console.error("Error sending to pingr:", error);
    }
  }

  return NextResponse.json({ message: "Analytics processed" });
}
