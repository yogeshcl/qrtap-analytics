# Get the current version from a file or use a default
VERSION=$(cat .version 2>/dev/null || echo "1.0.0")

# Increment version (example: add minor patch; you could also timestamp it)
NEW_VERSION=$(echo $VERSION | awk -F. -v OFS=. '{$NF += 1 ; print}')

# Save the new version
echo $NEW_VERSION > .version

# Build and tag the Docker image with the new version and the `latest` tag
docker build -t justwicks/qrtap-analytics:$NEW_VERSION -t justwicks/qrtap-analytics:latest .

# Push both tags
# docker push justwicks/qrtap-analytics:$NEW_VERSION
# docker push justwicks/qrtap-analytics:latest
# docker push --all-tags justwicks/qrtap-analytics

