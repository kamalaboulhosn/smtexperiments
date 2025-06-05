function extractField(message, field) {
  const data = JSON.parse(message.data);
  if (!(field in data)) {
    throw new Error("No field " + field);
  }
  return data[field];
}