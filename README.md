# Project Initialization
- After pulling the project, do the following to initialize the project:
    - Make sure that a Python Version >= 3.11 is installed
    - Run the following command to execute the initialization script: "source setup.sh"
- Create a .env file in the root directory with the following keys
    - OPENAI_API_KEY=your-key
    - REPLICATE_API_TOKEN=your-key
    - COHERE_API_KEY=your-key
    - HUGGING_FACE_API_KEY=your-key
    - CHROMA_PATH=path-to-chroma
    - PARENT_DOC_PATH=path-to-hierarchical-doc-store
    - TESSERACT_PATH=path-to-tesseract
    - VOYAGE_API_KEY=your-key
    - MISTRAL_API_KEY=your-key
- If you want to insert new PDF documents and update the document base, you first need to install Tesseract which is the OCR engine used in this code:
    - Download Tesseract Installer for Windows: https://github.com/UB-Mannheim/tesseract/wiki
    - For others, see here: https://tesseract-ocr.github.io/tessdoc/Installation.html
    - Set the .env TESSERACT_PATH to the installation path, e.g. "C:\Program Files\Tesseract-OCR\tesseract.exe"

# Project Structure

## Notebooks (/notebooks)
- /notebooks/finetuning: Notebook for fine-tuning an embedding model.
    - /notebooks/finetuning/datasets: Folder for the generated datasets.
- /notebooks/preprocess_and_index_building: All notebooks required to preprocess textual data and build the vector database / sparse index.
- /notebooks/retrieve_prompt_evaluate: All notebooks required to execute the RAG pipeline and evaluate its performance.

## Document preprocessing (/inputData)

There are three different types of documents: PDF, web and templates. For each document type there is logic on how to process, store and update the documents.

### PDF Files (/PDF)
- Directory structure:
    - PDF/cleaned: After manually cleaning the PDFs (removing pages), the PDFs should be moved manually to this folder
    - PDF/documents
        - /all_documents: JSON file for all processed PDF documents
        - /new_documents: JSON file for newly processed PDF documents
    - PDF/PDF_images: Empty folder in which the images during OCR are stored and deleted afterwards.
    - PDF/uncleaned: New PDFs from the web (found during search) should be stored in this folder in it's original state
- Methods:
    - update_pdf_documents:
        - Processes the PDF documents stored inside PDF/cleaned
        - **Should be executed every time new PDFs are stored in PDF/cleaned**
        - Looks at the path for each PDF file and if it does not contain "Tesseract_processed", it processes it
            - Each page of the PDF file is transformed to an image (PDF -> IMG) and the image is stored on the PDF/PDF_images folder
            - Then each image is transformed to text (IMG -> TXT) using the pytesseract library
            - The resulting text is stored inside a document
            - All processed documents are then stored under PDF/documents/new_documents
        - Otherwise skips it, as the processed document information is already stored inside PDF/documents/all_documents
    - get_pdf_documents: Just loads the stored documents from the paths PDF/documents/all_documents or PDF/documents/new_documents
        - All documents when building a new index
        - New documents when updating an existing index

### Web Files (/Web)
- Directory structure:
    - Web/documents:
        - /all_cleaned_documents: JSON file for all processed web documents
        - /newly_cleaned_documents: JSON file for newly processed web documents
    - Web/URLs:
        - /cleaned_urls.txt: .txt file for URLs that already were processed and documents exist
        - /uncleaned_urls.txt: .txt file for URLs that have not been processed
- Methods:
    - Notebook: a_preprocess_data
        - get_web_documents_for_cleaning: 
            - Looks at the .txt file with all uncleaned urls
            - Uses the AsyncHTMLoader and HTML2TextTransformer to get texts
            - This method is called in the notebook a_web_text_cleaning
        - get_web_documents: Just loads the stored documents from the paths Web/documents/all_cleaned_documents or Web/documents/newly_cleaned_documents
    - Notebook: a_web_text_cleaning
        - Calls get_web_documents_for_cleaning
        - User has to manually clean them
        - The document with the cleaned content are then stored under /all_cleaned_documents and /newly_cleaned_documents
        - **Should be executed every time new URLs are inside /uncleaned_urls.txt**

### Template Files (/Templates)
- Directory structure:
    - Templates/documents:
        - /all_documents: JSON file for all processed template documents
        - /new_documents:  JSON file for all newly processed template documents
    - Templates/template_files:
        - /new: Not yet processed template files
        - /processed: Already processed template files
- Methods:
    - Notebook: a_preprocess_data
        - get_template_documents: Just loads the stored documents from the paths Templates/documents/all_documents or Templates/documents/new_documents
    - Notebook: a_template_document_creation
        - Prints all template files in the /new_documents folder
        - For these file paths a new document has to be added
        - User has to manually create the specific documents
        - This document list is stored to /new_documents and /all_documents
        - The newly processed files are moved from the /new to the /processed folder
        - **Should be executed every time new templates are inside /new**

## Input for retrieval (/retrievalInput)
### Documents for Sparse Retrieval (/retrievalInput/Documents_For_Sparse)
In order to make the sparse retrieval work, the chunked documents need to be stored under retrievalInput/Documents_For_Sparse. This can be done by calling the method store_documents_for_sparse_retrieval inside the a_preprocess_data.ipynb notebook (see preprocess_and_index_building/main_all.ipynb)

### Queries (/retrievalInput/Queries)
In order to lower the amount of calls to the OpenAI API in the context of the multiple query retrieval strategy, the queries are stored under retrievalInput/Queries. For that the method generate_and_store_multiple_queries_list inside the b_retrieve_data_and_prompt notebook has to be executed once. For that a list of queries/prompts is needed, a boolean flag which indicates if the queries are used for evaluating only at the retrieval stage or the generation stage and the path where to store it. The path should contain all the metadata of the specific index (chunk size, overlap, embedding model ...) in order to load it later.

- Directory structure:
    - /Generation_Eval: Multi queries for generation evaluation
    - /Retrieval_Eval: Multi queries for retrieval evaluation

### HyDE_Documents (/retrievalInput/HyDE_Documents)
In order to lower the amount of calls to the OpenAI API in the context of the HyDE retrieval strategy, the documents associated to the queries are stored under retrievalInput/HyDE_Documents. For that the method generate_and_store_multiple_hyde_docs inside the b_retrieve_data_and_prompt notebook has to be executed once. For that a list of queries/prompts is needed, a boolean flag which indicates if the queries are used for evaluating only at the retrieval stage or the generation stage and the path where to store it. The path should contain all the metadata of the specific index (chunk size, overlap, embedding model ...) in order to load it later.

- Directory structure:
    - /Generation_Eval: HyDE documents for generation evaluation
    - /Retrieval_Eval: HyDE documents for retrieval evaluation

## Input for evaluation (/evaluationInput)
### (Question, Context) Pairs (/evaluationInput/retrieval_eval)
To evaluate the retrieval stage, question-context pairs are generated on a (chunk size, chunk overlap, file type, append title) combination level and stored in this directory. The method for generating them can be found under c_evaluation_retrieval.ipynb generate_and_store_question_context_pairs.

### Golden QA Set (/evaluationInput/generation_eval)
To evaluate the generation stage, the golden Q&A set is stored in this directory.

## Evaluation Results (/evaluationResults)
### Evaluation Results of Retrieval (/evaluationResults/retrievalEval)
Stores the results of the retrieval in a .csv. Following values are stored: index_name,retriever_method,number_retrieved_docs,hit_rate,mrr,similarity,duration

### Evaluation Results of Generation (/evaluationResults/generationEval)
#### Evaluation Results of Index, LLM and QA combination (/evaluationResults/generationEval/generation_single)
##### Standalone LLM (/evaluationResults/generationEval/generation_single/LLM_only)
Stores the results of the evaluation of one LLM and all QA questions. The following values are stored inside a .csv: llm_name,max_context_size,temperature,prompt_version,question,golden_answer,generated_answer,rouge1,rouge2,rougeL,answer_relevancy,answer_similarity,RAGAS_relevancy,duration_generation

##### RAG (/evaluationResults/generationEval/generation_single/RAG)
Stores the results of the evaluation of one index, LLM and all QA questions. Also stores the retrieved contexts and the generated answer. The following values are stored inside a .csv: index_name,retriever_method,number_retrieved_docs,llm_name,max_context_size,temperature,prompt_version,question,retrieved_contexts,golden_answer,generated_answer,context_size_valid,rouge1,rouge2,rougeL,hallucination,answer_relevancy,answer_similarity,context_recall,RAGAS_relevancy,duration_retrieval,duration_generation,duration_context_size,duration_total

#### Evaluation Result of all combinations (/evaluationResults/generationEval/generation_total)

##### Standalone LLM (/evaluationResults/generationEval/generation_total/LLM_only)
Stores the results of one complete evaluation run, meaning multiple llms.

##### RAG (/evaluationResults/generationEval/generation_total/RAG)
Stores the results of one complete evaluation run, meaning multiple indices and llm combinations.

## Parent Child Store (/parent_child_store)
The parent child store is a file store for storing the parent documents of the according child indexes. In the retrieval step the parent_id in the metadata of a child document is used to fetch the according parent from this file store. Each index has its own folder.