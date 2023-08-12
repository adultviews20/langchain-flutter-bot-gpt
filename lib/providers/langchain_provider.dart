import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class LangChainDartNotifier extends StateNotifier<String> {
  LangChainDartNotifier() : super('');

  Future readFileFromMobile(String textDocString, String textQuestion) async {
    const openaiApiKey = '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';

    const textSplitter = RecursiveCharacterTextSplitter(
      chunkSize: 4000,
      chunkOverlap: 0,
      separators: [" ", ",", "\n"]
    );

    final chunks = textSplitter.createDocuments([textDocString.toString()]);

    final embedding = OpenAIEmbeddings(apiKey: openaiApiKey);

    final vector = await embedding.embedQuery(chunks[0].pageContent);

    final vectorStore = await MemoryVectorStore.fromDocuments(
        documents: chunks, embeddings: embedding);

    const query = 'what is the name of the child?';
    final result = await vectorStore.similaritySearch(query: query);

    final llm = ChatOpenAI(
        model: 'gpt-3.5-turbo', temperature: 0, apiKey: openaiApiKey,);
    final retriever =
        vectorStore.asRetriever(searchType: VectorStoreSearchType.similarity);
    final chain = RetrievalQAChain.fromLlm(llm: llm, retriever: retriever);

    final res = await chain({
      RetrievalQAChain.defaultInputKey: textQuestion,
    });
    final answer = res[RetrievalQAChain.defaultOutputKey];

    print(answer);
    return answer;
  }
}

final langChainProvider = StateNotifierProvider<LangChainDartNotifier, String>(
    (ref) => LangChainDartNotifier());
