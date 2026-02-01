# AI Impact Statement

## What the AI Is Doing (Models & Rationale)
The system uses machine learning to **forecast parking occupancy and demand** and to **dynamically price parking spaces** in real time. Gradient-boosted models (XGBoost) and classical ML (scikit-learn) are chosen for their **high accuracy on tabular, multi-source time-series data**, fast inference, and explainability. Models ingest traffic congestion, weather conditions, temporal patterns, and event signals to generate availability heatmaps and pricing recommendations. :contentReference[oaicite:0]{index=0}

## Data Provenance & Licenses
Data is sourced from **public and licensed APIs**: traffic and geospatial data (Mapbox/Geoapify), weather data (OpenWeatherMap), and public event calendars (PredictHQ/Calendarific). User-generated data (bookings, check-ins, feedback) is collected with consent and stored securely. All third-party APIs are used in compliance with their respective licenses and terms.

## Hallucination, Bias Mitigation & Guardrails
Predictions are **bounded by real-world constraints** (capacity limits, booking state). Confidence scores are shown to users. Models are retrained with monitoring via MLflow, outliers are filtered, and no AI-generated text is presented as fact without verification. Sensitive attributes are not used.

## Expected Outcomes
**Users:** Reduced search time, guaranteed parking, fair pricing.  
**Businesses:** Higher utilization and revenue via dynamic pricing.  
**Safety & Cities:** Less congestion, lower emissions, auditable and explainable AI decisions.
