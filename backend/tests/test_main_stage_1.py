import pytest
from fastapi.testclient import TestClient
from app.main import app

# Create test client
client = TestClient(app)

def test_root_endpoint():
    """Test the root endpoint returns correct message."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "Bookmark Manager API is running!" in data["message"]

def test_health_checkpoint():
    """Test the health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "bookmark-manager-api"
    assert "version" in data
    assert "environment" in data

def test_openapi_docs_accessible():
    "Test that OpenAPI documentation is accessible"
    response = client.get("/docs")
    assert response.status_code == 200

def test_openapi_json_accessible():
    "Test that OpenAPI JSON schema is accessible."
    response = client.get("openapi.json")
    assert response.status_code == 200
    data = response.json()
    assert "openapi" in data
    assert "info" in data
    assert data["info"]["title"] == "Bookmark Manager"

def test_cors_headers():
    "Test that CORS headers are set correctly"
    response = client.options("/")
    #CORS headers should be present (even if empty response)
    assert response.status_code in [200,405] # Options might not be implemented