'use client';

import React from 'react';
import { cn } from '@/lib/utils';
import { Cloud, Github } from 'lucide-react';

interface ProviderBadgeProps {
    provider: 'aws' | 'gcp' | 'azure' | 'github';
    className?: string;
    showIcon?: boolean;
}

export function ProviderBadge({ provider, className, showIcon = true }: ProviderBadgeProps) {
    const styles = {
        aws: "bg-aws-orange/10 text-aws-orange border-aws-orange/20",
        gcp: "bg-gcp-blue/10 text-gcp-blue border-gcp-blue/20",
        azure: "bg-azure-blue/10 text-azure-blue border-azure-blue/20",
        github: "bg-white/10 text-white border-white/20",
    };

    const labels = {
        aws: "AWS",
        gcp: "Google Cloud",
        azure: "Azure",
        github: "GitHub",
    };

    return (
        <span className={cn(
            "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border",
            styles[provider],
            className
        )}>
            {showIcon && (
                <span className="mr-1.5">
                    {provider === 'github' ? <Github size={12} /> : <Cloud size={12} />}
                </span>
            )}
            {labels[provider]}
        </span>
    );
}
