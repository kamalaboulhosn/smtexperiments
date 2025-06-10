function verifyId(message, metadata) {
  const data = JSON.parse(message.data);
  const id = data["id"];
  if (!Number.isInteger(id) || id < 0) {
    throw new Error("ID is invalid");
  }
  return message;
}