#!/bin/bash
# Validation script for workload identity federation
# This script tests OIDC authentication across AWS, GCP, and Azure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
SKIPPED=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASSED++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((SKIPPED++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running in GitHub Actions
check_github_actions() {
    print_header "Environment Check"

    if [ -n "$GITHUB_ACTIONS" ]; then
        print_success "Running in GitHub Actions"
        print_info "Repository: $GITHUB_REPOSITORY"
        print_info "Ref: $GITHUB_REF"
        print_info "Actor: $GITHUB_ACTOR"
        print_info "Run ID: $GITHUB_RUN_ID"
    else
        print_warning "Not running in GitHub Actions"
        print_info "This script is designed to run in GitHub Actions workflows"
        return 1
    fi
}

# Validate AWS OIDC authentication
validate_aws() {
    print_header "AWS OIDC Validation"

    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not installed"
        return 1
    fi
    print_success "AWS CLI installed"

    # Check if credentials are configured (via OIDC)
    if aws sts get-caller-identity &> /dev/null; then
        print_success "AWS credentials configured"

        # Get caller identity
        IDENTITY=$(aws sts get-caller-identity)
        ACCOUNT_ID=$(echo "$IDENTITY" | jq -r '.Account')
        USER_ID=$(echo "$IDENTITY" | jq -r '.UserId')
        ARN=$(echo "$IDENTITY" | jq -r '.Arn')

        print_info "Account ID: $ACCOUNT_ID"
        print_info "User ID: $USER_ID"
        print_info "ARN: $ARN"

        # Verify it's an assumed role (not IAM user)
        if [[ $ARN == *"assumed-role"* ]]; then
            print_success "Authenticated via assumed role (OIDC)"
        else
            print_error "Not using assumed role - may be using long-lived credentials"
            return 1
        fi

        # Check if session name contains GitHub run ID
        if [[ $ARN == *"GitHubActions"* ]]; then
            print_success "Session name indicates GitHub Actions"
        else
            print_warning "Session name doesn't match expected pattern"
        fi

        # Test S3 access
        if aws s3 ls &> /dev/null; then
            print_success "S3 access verified"
        else
            print_warning "No S3 access or no buckets exist"
        fi

    else
        print_error "AWS credentials not configured"
        return 1
    fi
}

# Validate GCP Workload Identity
validate_gcp() {
    print_header "GCP Workload Identity Validation"

    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI not installed"
        return 1
    fi
    print_success "gcloud CLI installed"

    # Check if authenticated
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
        PROJECT=$(gcloud config get-value project 2>/dev/null)

        print_success "GCP credentials configured"
        print_info "Account: $ACCOUNT"
        print_info "Project: $PROJECT"

        # Verify it's a service account
        if [[ $ACCOUNT == *".gserviceaccount.com" ]]; then
            print_success "Authenticated via service account (Workload Identity)"
        else
            print_error "Not using service account - may be using long-lived credentials"
            return 1
        fi

        # Check if it's the GitHub Actions service account
        if [[ $ACCOUNT == *"github-actions"* ]]; then
            print_success "Using GitHub Actions service account"
        else
            print_warning "Service account name doesn't match expected pattern"
        fi

        # Test GCS access
        if gcloud storage buckets list --project="$PROJECT" &> /dev/null; then
            print_success "GCS access verified"
        else
            print_warning "No GCS access or permission denied"
        fi

    else
        print_error "GCP credentials not configured"
        return 1
    fi
}

# Validate Azure Federated Identity
validate_azure() {
    print_header "Azure Federated Identity Validation"

    # Check if az CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI not installed"
        return 1
    fi
    print_success "Azure CLI installed"

    # Check if authenticated
    if az account show &> /dev/null; then
        ACCOUNT_INFO=$(az account show)
        ACCOUNT_NAME=$(echo "$ACCOUNT_INFO" | jq -r '.name')
        TENANT_ID=$(echo "$ACCOUNT_INFO" | jq -r '.tenantId')
        SUBSCRIPTION_ID=$(echo "$ACCOUNT_INFO" | jq -r '.id')
        USER=$(echo "$ACCOUNT_INFO" | jq -r '.user.name')

        print_success "Azure credentials configured"
        print_info "Subscription: $ACCOUNT_NAME"
        print_info "Tenant ID: $TENANT_ID"
        print_info "Subscription ID: $SUBSCRIPTION_ID"
        print_info "User: $USER"

        # Check authentication type
        if az account show | jq -e '.user.type == "servicePrincipal"' &> /dev/null; then
            print_success "Authenticated via service principal (Federated Identity)"
        else
            print_warning "Not using service principal - authentication type: $(echo "$ACCOUNT_INFO" | jq -r '.user.type')"
        fi

        # Test resource group access
        if az group list &> /dev/null; then
            print_success "Resource group access verified"
        else
            print_warning "No resource group access or permission denied"
        fi

    else
        print_error "Azure credentials not configured"
        return 1
    fi
}

# Validate no long-lived credentials in environment
validate_no_credentials() {
    print_header "Credential Security Check"

    # Check for AWS credentials
    if [ -n "$AWS_ACCESS_KEY_ID" ]; then
        print_error "AWS_ACCESS_KEY_ID environment variable set - should not use long-lived credentials"
    else
        print_success "No AWS_ACCESS_KEY_ID in environment"
    fi

    if [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
        print_error "AWS_SECRET_ACCESS_KEY environment variable set - should not use long-lived credentials"
    else
        print_success "No AWS_SECRET_ACCESS_KEY in environment"
    fi

    # Check for GCP credentials
    if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        if [[ "$GOOGLE_APPLICATION_CREDENTIALS" == *".json" ]]; then
            print_error "GOOGLE_APPLICATION_CREDENTIALS points to JSON key file - should not use long-lived credentials"
        else
            print_success "GOOGLE_APPLICATION_CREDENTIALS set but not pointing to JSON key"
        fi
    else
        print_success "No GOOGLE_APPLICATION_CREDENTIALS in environment"
    fi

    # Check for Azure credentials
    if [ -n "$AZURE_CLIENT_SECRET" ]; then
        print_error "AZURE_CLIENT_SECRET environment variable set - should not use client secrets"
    else
        print_success "No AZURE_CLIENT_SECRET in environment"
    fi
}

# Test OIDC token claims (if available)
validate_oidc_token() {
    print_header "OIDC Token Validation"

    if [ -n "$ACTIONS_ID_TOKEN_REQUEST_URL" ]; then
        print_success "OIDC token request URL available"
        print_info "URL: $ACTIONS_ID_TOKEN_REQUEST_URL"

        # Request token from GitHub
        if [ -n "$ACTIONS_ID_TOKEN_REQUEST_TOKEN" ]; then
            TOKEN_URL="$ACTIONS_ID_TOKEN_REQUEST_URL&audience=sts.amazonaws.com"
            TOKEN=$(curl -s -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$TOKEN_URL" | jq -r '.value')

            if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
                print_success "OIDC token retrieved"

                # Decode token (without verification - just for inspection)
                PAYLOAD=$(echo "$TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null || echo "{}")

                SUB=$(echo "$PAYLOAD" | jq -r '.sub // empty')
                ISS=$(echo "$PAYLOAD" | jq -r '.iss // empty')
                AUD=$(echo "$PAYLOAD" | jq -r '.aud // empty')

                if [ -n "$SUB" ]; then
                    print_info "Subject: $SUB"

                    # Validate subject claim format
                    if [[ $SUB == repo:* ]]; then
                        print_success "Subject claim has correct format"
                    else
                        print_warning "Subject claim format unexpected"
                    fi
                fi

                if [ -n "$ISS" ]; then
                    print_info "Issuer: $ISS"

                    if [[ $ISS == "https://token.actions.githubusercontent.com" ]]; then
                        print_success "Issuer is GitHub Actions OIDC provider"
                    else
                        print_error "Unexpected issuer"
                    fi
                fi

                if [ -n "$AUD" ]; then
                    print_info "Audience: $AUD"
                fi

            else
                print_warning "Could not retrieve OIDC token"
            fi
        else
            print_warning "OIDC token request token not available"
        fi
    else
        print_warning "OIDC token request URL not available (not in GitHub Actions)"
    fi
}

# Main execution
main() {
    print_header "Keyless Kingdom Identity Validation"
    print_info "Validating workload identity federation across cloud providers"
    echo ""

    # Check environment
    check_github_actions || true

    # Validate OIDC token
    validate_oidc_token || true

    # Validate no long-lived credentials
    validate_no_credentials || true

    # Validate each cloud provider
    validate_aws || true
    validate_gcp || true
    validate_azure || true

    # Print summary
    print_header "Validation Summary"
    echo -e "${GREEN}Passed: $PASSED${NC}"
    echo -e "${RED}Failed: $FAILED${NC}"
    echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
    echo ""

    if [ $FAILED -eq 0 ]; then
        print_success "All validations passed!"
        exit 0
    else
        print_error "Some validations failed"
        exit 1
    fi
}

# Run main function
main "$@"
