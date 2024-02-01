import pickle
import re
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from google.cloud import storage

# If you haven't downloaded these resources before, you'll need to do so
nltk.download("stopwords")
nltk.download("wordnet")

# Initialize WordNetLemmatizer
lemmatizer = WordNetLemmatizer()


# Download the TF-IDF vectorizer and logistic regression model from GCS
def download_models():
    bucket_name = "sentiscope_bucket"  # Replace with your GCS bucket name
    client = storage.Client()
    bucket = client.get_bucket(bucket_name)

    blob_names = ["tfidf_vectorizer.pickle", "logistic_regression_model.pickle"]

    for blob_name in blob_names:
        blob = bucket.blob(blob_name)
        destination_path = f"/tmp/{blob_name}"
        blob.download_to_filename(destination_path)


# Load the TF-IDF vectorizer and logistic regression model
def load_models():
    with open("/tmp/tfidf_vectorizer.pickle", "rb") as file:
        loaded_vectorizer = pickle.load(file)
    with open("/tmp/logistic_regression_model.pickle", "rb") as file:
        lr_model = pickle.load(file)
    return loaded_vectorizer, lr_model


# Decode the sentiment label
def decode_sentiment(encoded_sentiment):
    sentiment_labels = {0: "Negative", 1: "Neutral", 2: "Positive"}
    return sentiment_labels[encoded_sentiment]


# Preprocess the text
def preprocess_text(text):
    # Remove any special characters, numbers, and punctuations
    text = re.sub(r"[^a-zA-Z\s]", "", text, re.I | re.A)

    # Convert to lowercase
    text = text.lower()

    # Tokenization, stopword removal, and lemmatization
    tokens = text.split()
    tokens = [
        lemmatizer.lemmatize(token)
        for token in tokens
        if token not in stopwords.words("english")
    ]

    return " ".join(tokens)


# Perform sentiment analysis
def analyze_sentiment(request):
    request_json = request.get_json()
    user_input = request_json.get("review")

    # Download models from GCS if not already downloaded
    download_models()

    # Load the TF-IDF vectorizer and logistic regression model
    loaded_vectorizer, lr_model = load_models()

    # Preprocess and vectorize the input text
    preprocessed_input = preprocess_text(user_input)
    vectorized_input = loaded_vectorizer.transform([preprocessed_input])

    # Predict using the logistic regression model
    prediction = lr_model.predict(vectorized_input)
    probabilities = lr_model.predict_proba(vectorized_input)

    # Decode the sentiment label and format probabilities
    sentiment = decode_sentiment(prediction[0])
    negative_prob, neutral_prob, positive_prob = probabilities[0]

    # Prepare response
    response = {
        "sentiment": sentiment,
        "probabilities": {
            "Negative": round(negative_prob * 100, 2),
            "Neutral": round(neutral_prob * 100, 2),
            "Positive": round(positive_prob * 100, 2),
        },
    }

    return response
