// ThinkStrike - Performance Visualization
// Last Updated: 2025-08-07 15:21:17
// Author: Ruthvik-Anne

class PerformanceVisualizer {
    constructor() {
        this.charts = {};
        this.loadCharts();
    }

    async loadCharts() {
        const data = await this.fetchPerformanceData();
        this.createProgressChart(data.progress);
        this.createStrengthsChart(data.strengths);
        this.createTimelineChart(data.timeline);
    }

    createProgressChart(data) {
        this.charts.progress = new Chart('progressChart', {
            type: 'radar',
            data: {
                labels: data.categories,
                datasets: [{
                    label: 'Current Performance',
                    data: data.scores,
                    fill: true,
                    backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    borderColor: 'rgb(54, 162, 235)',
                    pointBackgroundColor: 'rgb(54, 162, 235)',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgb(54, 162, 235)'
                }]
            },
            options: {
                elements: {
                    line: { tension: 0.4 }
                }
            }
        });
    }

    createStrengthsChart(data) {
        this.charts.strengths = new Chart('strengthsChart', {
            type: 'horizontalBar',
            data: {
                labels: data.topics,
                datasets: [{
                    label: 'Performance by Topic',
                    data: data.scores,
                    backgroundColor: data.scores.map(score => 
                        score >= 80 ? 'rgba(75, 192, 192, 0.2)' :
                        score >= 60 ? 'rgba(54, 162, 235, 0.2)' :
                        'rgba(255, 99, 132, 0.2)'
                    ),
                    borderColor: data.scores.map(score =>
                        score >= 80 ? 'rgb(75, 192, 192)' :
                        score >= 60 ? 'rgb(54, 162, 235)' :
                        'rgb(255, 99, 132)'
                    ),
                    borderWidth: 1
                }]
            },
            options: {
                indexAxis: 'y',
                scales: {
                    x: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });
    }

    createTimelineChart(data) {
        this.charts.timeline = new Chart('timelineChart', {
            type: 'line',
            data: {
                labels: data.dates,
                datasets: [{
                    label: 'Quiz Scores Over Time',
                    data: data.scores,
                    fill: false,
                    borderColor: 'rgb(75, 192, 192)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });
    }

    async fetchPerformanceData() {
        const response = await fetch('/api/student/performance');
        return await response.json();
    }
}

// Initialize performance visualizer
const visualizer = new PerformanceVisualizer();