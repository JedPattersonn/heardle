import { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Privacy Policy - MusIQ",
  description: "Privacy Policy for MusIQ music guessing game and iOS app.",
};

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-8">
            Privacy Policy
          </h1>

          <div className="prose prose-lg max-w-none">
            <p className="text-gray-600 mb-6">
              <strong>Last updated:</strong> {new Date().toLocaleDateString()}
            </p>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                1. Information We Collect
              </h2>
              <p className="text-gray-700 mb-4">
                MusIQ does not collect or store any personal information that
                can be tied to individual users. We only collect anonymous
                analytics data through third-party services to improve the app
                experience:
              </p>
              <ul className="list-disc pl-6 text-gray-700 mb-4">
                <li>Anonymous usage analytics (page views, interactions)</li>
                <li>Anonymous performance metrics</li>
                <li>General device and browser information (anonymized)</li>
              </ul>
              <p className="text-gray-700 mb-4">
                <strong>Important:</strong> We do not store game scores, search
                queries, or any user-identifiable information on our servers.
              </p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                2. How We Use Information
              </h2>
              <p className="text-gray-700 mb-4">
                The anonymous analytics data is used solely to:
              </p>
              <ul className="list-disc pl-6 text-gray-700 mb-4">
                <li>Understand how users interact with the app</li>
                <li>Identify and fix technical issues</li>
                <li>Improve app performance and features</li>
                <li>Monitor app stability and usage patterns</li>
              </ul>
              <p className="text-gray-700 mb-4">
                All data is aggregated and cannot be used to identify individual
                users.
              </p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                3. Apple Music Integration
              </h2>
              <p className="text-gray-700 mb-4">
                Our app integrates with Apple Music to provide song previews and
                artist information. When you use this feature:
              </p>
              <ul className="list-disc pl-6 text-gray-700 mb-4">
                <li>
                  We access Apple Music&apos;s catalog through their official
                  API
                </li>
                <li>No personal Apple Music data is stored on our servers</li>
                <li>Song previews are streamed directly from Apple Music</li>
                <li>
                  Your Apple Music subscription status is not accessed or stored
                </li>
              </ul>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                4. Data Storage and Security
              </h2>
              <p className="text-gray-700 mb-4">
                Since we do not store any user data ourselves, there are minimal
                security concerns:
              </p>
              <ul className="list-disc pl-6 text-gray-700 mb-4">
                <li>No personal information is stored on our servers</li>
                <li>
                  All analytics data is handled by third-party services
                  (PostHog, Vercel)
                </li>
                <li>
                  Game scores and progress are stored locally on your device
                  only
                </li>
                <li>We cannot access or retrieve any personal game data</li>
              </ul>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                5. Third-Party Services
              </h2>
              <p className="text-gray-700 mb-4">
                Our app uses the following third-party services:
              </p>
              <ul className="list-disc pl-6 text-gray-700 mb-4">
                <li>
                  <strong>Apple Music API:</strong> For song previews and artist
                  data
                </li>
                <li>
                  <strong>PostHog:</strong> For analytics and app improvement
                </li>
                <li>
                  <strong>Vercel:</strong> For hosting and performance
                  monitoring
                </li>
              </ul>
              <p className="text-gray-700 mb-4">
                These services have their own privacy policies that govern their
                collection and use of information.
              </p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                6. Your Rights
              </h2>
              <p className="text-gray-700 mb-4">
                Since we do not store personal data:
              </p>
              <ul className="list-disc pl-6 text-gray-700 mb-4">
                <li>
                  There is no personal information to access or delete from our
                  servers
                </li>
                <li>
                  You can clear your local game data by clearing your browser
                  storage
                </li>
                <li>
                  You can opt out of analytics by using browser privacy settings
                  or ad blockers
                </li>
                <li>
                  Contact us with any privacy concerns at privacy@getmusiq.app
                </li>
              </ul>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                7. Children&apos;s Privacy
              </h2>
              <p className="text-gray-700 mb-4">
                Our service is not directed to children under 13. We do not
                knowingly collect personal information from children under 13.
                If you are a parent or guardian and believe your child has
                provided us with personal information, please contact us.
              </p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                8. Changes to This Policy
              </h2>
              <p className="text-gray-700 mb-4">
                We may update this privacy policy from time to time. We will
                notify you of any changes by posting the new privacy policy on
                this page and updating the &quot;Last updated&quot; date.
              </p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">
                9. Contact Us
              </h2>
              <p className="text-gray-700 mb-4">
                If you have any questions about this Privacy Policy, please
                contact us at:
              </p>
              <p className="text-gray-700">Email: privacy@getmusiq.app</p>
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
