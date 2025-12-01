'use client';

import React, { useState } from 'react';
import { KingdomShell } from '@/components/layout/KingdomShell';
import { ProviderBadge } from '@/components/ui/ProviderBadge';
import { Copy, Check, GitBranch, Play, Shield } from 'lucide-react';
import { motion } from 'framer-motion';

export default function WorkflowIntegration() {
    const [copied, setCopied] = useState(false);
    const [selectedProvider, setSelectedProvider] = useState<'aws' | 'gcp' | 'azure'>('aws');

    const workflows = {
        aws: `name: AWS OIDC Example
on:
  push:
    branches: [ main ]
permissions:
  id-token: write # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionRole
          aws-region: us-east-1

      - name: Verify Identity
        run: aws sts get-caller-identity`,
        azure: `name: Azure OIDC Example
on:
  push:
    branches: [ main ]
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: \${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: \${{ secrets.AZURE_TENANT_ID }}
          subscription-id: \${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Verify Identity
        run: az account show`,
        gcp: `name: GCP OIDC Example
on:
  push:
    branches: [ main ]
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider
          service_account: my-service-account@my-project.iam.gserviceaccount.com

      - name: Verify Identity
        run: gcloud auth list`
    };

    const handleCopy = () => {
        navigator.clipboard.writeText(workflows[selectedProvider]);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
    };

    return (
        <KingdomShell>
            <div className="max-w-6xl mx-auto space-y-8">
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-3xl font-cal text-white mb-2">Workflow Integration</h1>
                        <p className="text-zinc-400">Drop-in GitHub Actions workflows for keyless authentication.</p>
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Sidebar */}
                    <div className="space-y-6">
                        <div className="bg-black/20 border border-white/10 rounded-2xl p-6 backdrop-blur-sm">
                            <h3 className="text-lg font-medium text-white mb-4">Select Provider</h3>
                            <div className="space-y-3">
                                {(['aws', 'azure', 'gcp'] as const).map((p) => (
                                    <button
                                        key={p}
                                        onClick={() => setSelectedProvider(p)}
                                        className={`w-full flex items-center justify-between p-3 rounded-xl border transition-all ${selectedProvider === p
                                                ? 'bg-indigo-500/10 border-indigo-500/50 ring-1 ring-indigo-500/50'
                                                : 'bg-white/5 border-white/10 hover:bg-white/10'
                                            }`}
                                    >
                                        <div className="flex items-center gap-3">
                                            <ProviderBadge provider={p} />
                                            <span className="text-zinc-200 font-medium uppercase">{p}</span>
                                        </div>
                                        {selectedProvider === p && <div className="w-2 h-2 rounded-full bg-indigo-500 shadow-[0_0_8px_rgba(99,102,241,0.8)]" />}
                                    </button>
                                ))}
                            </div>
                        </div>

                        <div className="bg-indigo-900/10 border border-indigo-500/20 rounded-2xl p-6">
                            <div className="flex items-center gap-3 mb-3">
                                <Shield className="w-5 h-5 text-indigo-400" />
                                <h3 className="text-lg font-medium text-white">Security Note</h3>
                            </div>
                            <p className="text-sm text-zinc-400 leading-relaxed">
                                Ensure you request the <code className="text-indigo-300 bg-indigo-500/10 px-1 rounded">id-token: write</code> permission in your workflow. This is required for the OIDC token to be generated by GitHub.
                            </p>
                        </div>
                    </div>

                    {/* Code View */}
                    <div className="lg:col-span-2">
                        <motion.div
                            key={selectedProvider}
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ duration: 0.3 }}
                            className="bg-[#0D1117] border border-white/10 rounded-2xl overflow-hidden shadow-2xl"
                        >
                            <div className="flex items-center justify-between px-4 py-3 border-b border-white/10 bg-white/5">
                                <div className="flex items-center gap-2">
                                    <GitBranch className="w-4 h-4 text-zinc-500" />
                                    <span className="text-sm font-mono text-zinc-300">.github/workflows/deploy.yml</span>
                                </div>
                                <button
                                    onClick={handleCopy}
                                    className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 hover:bg-white/10 text-xs font-medium text-zinc-300 transition-colors"
                                >
                                    {copied ? <Check className="w-3 h-3 text-emerald-400" /> : <Copy className="w-3 h-3" />}
                                    {copied ? 'Copied!' : 'Copy Code'}
                                </button>
                            </div>
                            <div className="p-6 overflow-x-auto">
                                <pre className="font-mono text-sm leading-relaxed">
                                    <code className="text-zinc-300">
                                        {workflows[selectedProvider]}
                                    </code>
                                </pre>
                            </div>
                        </motion.div>

                        <div className="mt-6 flex items-center justify-end gap-4">
                            <button className="flex items-center gap-2 px-4 py-2 rounded-lg text-zinc-400 hover:text-white transition-colors">
                                <Play className="w-4 h-4" />
                                <span>Test Workflow</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </KingdomShell>
    );
}
