"""
ThinkStrike - Documentation Generator
Created: 2025-08-07 15:35:50
Author: Ruthvik-Anne
"""

import json
from datetime import datetime

def generate_html_docs():
    """Generate HTML documentation"""
    
    api_endpoints = [
        {
            "path": "/api/auth/login",
            "method": "POST",
            "description": "User authentication",
            "parameters": ["roll_number", "password"]
        },
        {
            "path": "/api/quizzes",
            "method": "GET",
            "description": "Get available quizzes",
            "parameters": ["page", "limit"]
        },
        {
            "path": "/api/reports/create",
            "method": "POST",
            "description": "Create question report",
            "parameters": ["question_id", "report_type"]
        }
    ]

    html = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ThinkStrike API Documentation</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                line-height: 1.6;
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
            }}
            .endpoint {{
                border: 1px solid #ddd;
                margin: 10px 0;
                padding: 15px;
                border-radius: 5px;
            }}
            .method {{
                display: inline-block;
                padding: 3px 8px;
                border-radius: 3px;
                color: white;
                background-color: #0066cc;
            }}
        </style>
    </head>
    <body>
        <h1>ThinkStrike API Documentation</h1>
        <p>Generated: 2025-08-07 15:35:50</p>
        
        <h2>API Endpoints</h2>
        {''.join([f'''
        <div class="endpoint">
            <span class="method">{endpoint['method']}</span>
            <strong>{endpoint['path']}</strong>
            <p>{endpoint['description']}</p>
            <h4>Parameters:</h4>
            <ul>
                {''.join([f'<li>{param}</li>' for param in endpoint['parameters']])}
            </ul>
        </div>
        ''' for endpoint in api_endpoints])}
    </body>
    </html>
    """
    
    return html

if __name__ == "__main__":
    print(generate_html_docs())