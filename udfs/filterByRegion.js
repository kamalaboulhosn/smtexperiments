function filterByRegion(message, metadata) {
  region = extractField(message, "region");
  if (region != "US") {
    return null;
  }
  return message;
}