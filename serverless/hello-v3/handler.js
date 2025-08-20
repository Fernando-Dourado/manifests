module.exports.hello = async () => {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Hello from Serverless v3! release: 2" }),
  };
};
