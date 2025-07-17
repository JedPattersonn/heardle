import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Home, Search } from "lucide-react";

export default function NotFound() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <div className="text-center space-y-6 max-w-md">
        <div className="space-y-4">
          <h1 className="text-4xl font-bold">Artist Not Found</h1>
          <p className="text-lg text-muted-foreground">
            Sorry, we couldn&apos;t find the artist you&apos;re looking for.
            They might not be in our collection yet.
          </p>
        </div>

        <div className="space-y-3">
          <Button asChild size="lg" className="w-full">
            <Link href="/">
              <Home className="w-4 h-4 mr-2" />
              Go to Homepage
            </Link>
          </Button>

          <Button asChild variant="outline" size="lg" className="w-full">
            <Link href="/#search">
              <Search className="w-4 h-4 mr-2" />
              Search for Artists
            </Link>
          </Button>
        </div>

        <p className="text-sm text-muted-foreground">
          Can&apos;t find your favorite artist? They might be available through
          our search feature.
        </p>
      </div>
    </div>
  );
}
