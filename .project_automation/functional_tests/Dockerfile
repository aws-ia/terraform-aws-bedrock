FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:4.0
ENV TERRAFORM_VERSION=1.7.4
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && chmod 755 /usr/local/bin/terraform