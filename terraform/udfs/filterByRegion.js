function filterByRegion(message, metadata) {
  region = extractField(message, "region");
  if (region === "US") {
    return message;
  }
  return null;
}