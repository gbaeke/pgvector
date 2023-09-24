import os
import getpass

# read from .env file
from dotenv import load_dotenv
load_dotenv()

from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.text_splitter import CharacterTextSplitter
from langchain.vectorstores import Qdrant
from langchain.document_loaders import TextLoader
from langchain.chains import RetrievalQA
from langchain.llms import OpenAI


loader = TextLoader("./state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()

url = "https://qdrant-bluu.hndph9ghcqerengf.westeurope.azurecontainer.io:443"
qdrant = Qdrant.from_documents(
    docs,
    embeddings,
    url=url,
    prefer_grpc=False,
    collection_name="docs",
    timeout=60,
    api_key="TOPSECRET"
)

retriever = qdrant.as_retriever()

query = "What did the president say about Ketanji Brown Jackson"

qa = RetrievalQA.from_chain_type(llm=OpenAI(), chain_type="stuff", retriever=retriever)

answer = qa.run(query)

print(answer)

