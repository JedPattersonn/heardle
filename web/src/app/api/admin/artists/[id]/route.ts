import { NextResponse } from "next/server";
import { db } from "@/db";
import { artists } from "@/db/schema";
import { eq } from "drizzle-orm";

// PUT /api/admin/artists/[id] - Update an artist
export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const body = await request.json();
    const { name, imageUrl, genres, category, sortOrder, isActive } = body;
    const artistId = parseInt((await params).id);

    if (isNaN(artistId)) {
      return NextResponse.json({ error: "Invalid artist ID" }, { status: 400 });
    }

    const updatedArtist = await db
      .update(artists)
      .set({
        name,
        imageUrl,
        genres,
        category,
        sortOrder,
        isActive,
        updatedAt: new Date(),
      })
      .where(eq(artists.id, artistId))
      .returning();

    if (updatedArtist.length === 0) {
      return NextResponse.json({ error: "Artist not found" }, { status: 404 });
    }

    return NextResponse.json(updatedArtist[0]);
  } catch (error) {
    console.error("Failed to update artist:", error);
    return NextResponse.json(
      { error: "Failed to update artist" },
      { status: 500 }
    );
  }
}

// DELETE /api/admin/artists/[id] - Delete an artist
export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const artistId = parseInt((await params).id);

    if (isNaN(artistId)) {
      return NextResponse.json({ error: "Invalid artist ID" }, { status: 400 });
    }

    const deletedArtist = await db
      .delete(artists)
      .where(eq(artists.id, artistId))
      .returning();

    if (deletedArtist.length === 0) {
      return NextResponse.json({ error: "Artist not found" }, { status: 404 });
    }

    return NextResponse.json({ message: "Artist deleted successfully" });
  } catch (error) {
    console.error("Failed to delete artist:", error);
    return NextResponse.json(
      { error: "Failed to delete artist" },
      { status: 500 }
    );
  }
}
