#!/bin/bash
python -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
echo "Virtual environment activated and requirements installed."

# Creating all necessary directories at once
mkdir -p ./inputData/PDF/cleaned \
         ./inputData/PDF/PDF_images \
         ./inputData/PDF/uncleaned \
         ./inputData/PDF/documents \
         ./inputData/Web/documents \
         ./inputData/Web/URLs \
         ./inputData/Templates/documents \
         ./inputData/Templates/template_files/new \
         ./inputData/Templates/template_files/processed \
         ./retrievalInput/Documents_For_Sparse \
         ./retrievalInput/Queries \
         ./retrievalInput/HyDE_Documents \
         ./chroma \
         ./parent_child_store \
         ./evaluationInput/retrieval_eval \
         ./evaluationInput/generation_eval \
         ./evaluationResults/retrievalEval \
         ./evaluationResults/generationEval/generation_single/LLM_only \
         ./evaluationResults/generationEval/generation_single/RAG \
         ./evaluationResults/generationEval/generation_total/LLM_only \
         ./evaluationResults/generationEval/generation_total/RAG \
         ./notebooks/finetuning/datasets

# Creating files
touch ./inputData/PDF/documents/all_documents \
      ./inputData/PDF/documents/new_documents \
      ./inputData/Web/documents/all_cleaned_documents \
      ./inputData/Web/documents/newly_cleaned_documents \
      ./inputData/Web/URLs/cleaned_urls.txt \
      ./inputData/Web/URLs/uncleaned_urls.txt \
      ./inputData/Templates/documents/all_documents \
      ./inputData/Templates/documents/new_documents

echo "Directories and necessary files created."