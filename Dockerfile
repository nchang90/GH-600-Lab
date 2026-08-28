# The application has no third-party dependencies, so there is no install step
# and no package manager in the final image.
FROM python:3.12-slim

WORKDIR /srv
COPY app/ ./app/

ENV PORT=8000
EXPOSE 8000

# Run as a non-root user. An agent that gains execution inside this container
# should not also gain the ability to modify it.
RUN useradd --create-home --uid 10001 appuser
USER appuser

CMD ["python", "-m", "app.api"]
