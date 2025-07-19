import { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Support - Heardle.fun",
  description:
    "Get help and support for Heardle.fun music guessing game and iOS app.",
};

export default function SupportPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-8">Support</h1>

          <div className="prose prose-lg max-w-none">
            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                Need Help?
              </h2>
              <p className="text-gray-700 mb-6">
                We&apos;re here to help! If you&apos;re experiencing issues with
                Heardle.fun or have questions about the game, please don&apos;t
                hesitate to reach out.
              </p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                Contact Us
              </h2>
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
                <h3 className="text-xl font-semibold text-blue-900 mb-3">
                  Email Support
                </h3>
                <p className="text-gray-700 mb-4">
                  For technical issues, feature requests, or general questions:
                </p>
                <p className="text-lg font-semibold text-blue-800">
                  <a
                    href="mailto:support@heardle.fun"
                    className="hover:underline"
                  >
                    support@heardle.fun
                  </a>
                </p>
              </div>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                Common Issues
              </h2>
              <div className="space-y-4">
                <div className="border-l-4 border-gray-300 pl-4">
                  <h4 className="font-semibold text-gray-900 mb-2">
                    Songs won&apos;t play
                  </h4>
                  <p className="text-gray-700">
                    Make sure your device volume is up and you have a stable
                    internet connection. Songs are streamed from Apple Music.
                  </p>
                </div>

                <div className="border-l-4 border-gray-300 pl-4">
                  <h4 className="font-semibold text-gray-900 mb-2">
                    Can&apos;t find an artist
                  </h4>
                  <p className="text-gray-700">
                    Try different spellings or search for the artist&apos;s most
                    popular name. We use Apple Music&apos;s catalog for artist
                    data.
                  </p>
                </div>

                <div className="border-l-4 border-gray-300 pl-4">
                  <h4 className="font-semibold text-gray-900 mb-2">
                    Game progress lost
                  </h4>
                  <p className="text-gray-700">
                    Game scores are stored locally on your device. Clearing
                    browser data or app storage will reset your progress.
                  </p>
                </div>
              </div>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                When Contacting Support
              </h2>
              <p className="text-gray-700 mb-4">
                To help us assist you better, please include:
              </p>
              <ul className="list-disc pl-6 text-gray-700 mb-4">
                <li>Device type (iPhone, iPad, Web browser)</li>
                <li>Operating system version</li>
                <li>Description of the issue</li>
                <li>Steps to reproduce the problem</li>
                <li>Any error messages you see</li>
              </ul>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                Response Time
              </h2>
              <p className="text-gray-700 mb-4">
                We typically respond to support emails within 24-48 hours.
                During peak times or holidays, responses may take slightly
                longer.
              </p>
            </section>
          </div>

          <div className="mt-12 pt-8 border-t border-gray-200">
            <div className="text-center space-x-8">
              <Link
                href="/"
                className="text-blue-600 hover:text-blue-800 transition-colors"
              >
                Back to Game
              </Link>
              <Link
                href="/privacy"
                className="text-blue-600 hover:text-blue-800 transition-colors"
              >
                Privacy Policy
              </Link>
              <Link
                href="/terms"
                className="text-blue-600 hover:text-blue-800 transition-colors"
              >
                Terms of Service
              </Link>
              <Link
                href="/ios"
                className="text-blue-600 hover:text-blue-800 transition-colors"
              >
                iOS App
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
