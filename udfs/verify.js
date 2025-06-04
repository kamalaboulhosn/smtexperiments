function validateAmount(message, metadata) {
  const data = JSON.parse(message.data);
  if (data["id"] < 0) {
    throw new Error("ID is invalid");
  }
  return message;
}