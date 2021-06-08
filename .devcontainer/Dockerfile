#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/azure-functions/dotnet:3.0-dotnet3-core-tools

# [Optional] Install Terrafrom
ARG INSTALL_TERRAFORM="true"
ARG TERRAFORM_VERSION=1.0.0
ARG TFLINT_VERSION=0.29.0

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install \
        unzip \
    #
    # [Optional] Install Terraform, tflint, and graphviz
    && if [ "$INSTALL_TERRAFORM" = "true" ]; then \
        #    
        mkdir -p /tmp/docker-downloads \
        && curl -sSL -o /tmp/docker-downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
        && unzip /tmp/docker-downloads/terraform.zip \
        && mv terraform /usr/local/bin \
        && curl -sSL -o /tmp/docker-downloads/tflint.zip https://github.com/wata727/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
        && unzip /tmp/docker-downloads/tflint.zip \
        && mv tflint /usr/local/bin \
        && cd ~ \ 
        && rm -rf /tmp/docker-downloads \
        && apt-get install -y graphviz; \
    fi \    
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Opt out of Func CLI telemetry gathering
#ENV FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=true

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog