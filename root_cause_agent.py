#!/usr/bin/env python3
"""
獨立思考根因分析Agent
專注於深度問題分析和根本原因識別
"""

import json
import time
from datetime import datetime
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from enum import Enum
import click
from rich.console import Console
from rich.table import Table
from rich.progress import Progress
import yaml

console = Console()

class AnalysisLevel(Enum):
    """分析深度級別"""
    SURFACE = "surface"
    PATTERN = "pattern" 
    DEEP = "deep"
    SYSTEMIC = "systemic"
    META = "meta"

class ConfidenceLevel(Enum):
    """置信度級別"""
    LOW = 0.3
    MEDIUM = 0.6
    HIGH = 0.8
    VERY_HIGH = 0.95

@dataclass
class ProblemContext:
    """問題上下文"""
    title: str
    description: str
    symptoms: List[str]
    environment: Dict[str, Any] = None
    category: str = "general"
    urgency: str = "medium"
    
    def __post_init__(self):
        if self.environment is None:
            self.environment = {}

@dataclass
class RootCause:
    """根本原因"""
    cause: str
    confidence: float
    evidence: List[str]
    impact_level: str
    category: str

@dataclass
class AnalysisStep:
    """分析步驟"""
    step_name: str
    insight: str
    confidence: float
    reasoning: str
    timestamp: datetime

@dataclass
class RootCauseReport:
    """根因分析報告"""
    problem: ProblemContext
    root_causes: List[RootCause]
    analysis_steps: List[AnalysisStep]
    recommendations: List[str]
    total_confidence: float
    analysis_duration: float

class KnowledgeBase:
    """知識庫管理"""
    
    def __init__(self):
        self.patterns = self._load_patterns()
        self.case_studies = self._load_case_studies()
    
    def _load_patterns(self) -> Dict[str, Any]:
        """加載分析模式"""
        return {
            "tech_failure": {
                "symptoms": {
                    "performance_degradation": [
                        "response_time_increase", "timeout_errors", "high_cpu_usage"
                    ],
                    "system_crashes": [
                        "unexpected_shutdown", "memory_errors", "service_unavailable"
                    ]
                },
                "root_causes": [
                    "resource_bottleneck", "inefficient_algorithms", 
                    "database_issues", "network_latency", "configuration_errors"
                ]
            },
            "business_process": {
                "symptoms": {
                    "customer_complaints": [
                        "negative_feedback", "support_tickets", "churn_increase"
                    ],
                    "revenue_decline": [
                        "sales_drop", "conversion_decrease", "market_share_loss"
                    ]
                },
                "root_causes": [
                    "process_inefficiency", "communication_gap", 
                    "quality_issues", "market_changes", "competition"
                ]
            }
        }
    
    def _load_case_studies(self) -> List[Dict[str, Any]]:
        """加載案例研究"""
        return [
            {
                "title": "電商網站性能優化",
                "problem": "頁面加載時間超過10秒",
                "root_cause": "數據庫查詢未優化",
                "solution": "添加複合索引和查詢優化"
            },
            {
                "title": "客戶流失分析",
                "problem": "月活躍用戶下降30%",
                "root_cause": "新用戶引導流程複雜",
                "solution": "簡化註冊流程和改進用戶體驗"
            }
        ]
    
    def find_similar_cases(self, problem: ProblemContext) -> List[Dict[str, Any]]:
        """查找相似案例"""
        similar_cases = []
        for case in self.case_studies:
            similarity = self._calculate_similarity(problem.description, case["problem"])
            if similarity > 0.7:
                similar_cases.append({
                    **case,
                    "similarity": similarity
                })
        return similar_cases
    
    def _calculate_similarity(self, text1: str, text2: str) -> float:
        """簡單相似度計算"""
        words1 = set(text1.lower().split())
        words2 = set(text2.lower().split())
        intersection = words1.intersection(words2)
        return len(intersection) / max(len(words1), len(words2)) if max(len(words1), len(words2)) > 0 else 0

class DeepThinkingEngine:
    """深度思考引擎"""
    
    def __init__(self, knowledge_base: KnowledgeBase):
        self.knowledge_base = knowledge_base
    
    def analyze(self, problem: ProblemContext) -> List[AnalysisStep]:
        """執行深度分析"""
        steps = []
        
        # 1. 表面分析
        surface_insight = self._surface_analysis(problem)
        steps.append(AnalysisStep(
            step_name="surface_analysis",
            insight=surface_insight["insight"],
            confidence=surface_insight["confidence"],
            reasoning=surface_insight["reasoning"],
            timestamp=datetime.now()
        ))
        
        # 2. 模式識別
        pattern_insight = self._pattern_recognition(problem)
        steps.append(AnalysisStep(
            step_name="pattern_recognition",
            insight=pattern_insight["insight"],
            confidence=pattern_insight["confidence"],
            reasoning=pattern_insight["reasoning"],
            timestamp=datetime.now()
        ))
        
        # 3. 深度挖掘
        deep_insight = self._deep_analysis(problem, steps)
        steps.append(AnalysisStep(
            step_name="deep_analysis",
            insight=deep_insight["insight"],
            confidence=deep_insight["confidence"],
            reasoning=deep_insight["reasoning"],
            timestamp=datetime.now()
        ))
        
        # 4. 系統性思考
        systemic_insight = self._systemic_thinking(problem, steps)
        steps.append(AnalysisStep(
            step_name="systemic_thinking",
            insight=systemic_insight["insight"],
            confidence=systemic_insight["confidence"],
            reasoning=systemic_insight["reasoning"],
            timestamp=datetime.now()
        ))
        
        return steps
    
    def _surface_analysis(self, problem: ProblemContext) -> Dict[str, Any]:
        """表面層次分析"""
        # 基於症狀的初步分析
        symptom_patterns = []
        for symptom in problem.symptoms:
            for category, patterns in self.knowledge_base.patterns.items():
                for pattern_type, symptoms in patterns["symptoms"].items():
                    if any(s in symptom.lower() for s in symptoms):
                        symptom_patterns.append(f"{category}.{pattern_type}")
        
        return {
            "insight": f"初步分析顯示問題可能屬於：{', '.join(set(symptom_patterns))}",
            "confidence": 0.6,
            "reasoning": "基於症狀匹配識別可能的問題類型"
        }
    
    def _pattern_recognition(self, problem: ProblemContext) -> Dict[str, Any]:
        """模式識別"""
        similar_cases = self.knowledge_base.find_similar_cases(problem)
        
        if similar_cases:
            top_case = max(similar_cases, key=lambda x: x["similarity"])
            return {
                "insight": f"發現相似案例：{top_case['title']}，根因可能是：{top_case['root_cause']}",
                "confidence": 0.75,
                "reasoning": f"基於歷史案例匹配，相似度：{top_case['similarity']:.2f}"
            }
        
        return {
            "insight": "未找到相似案例，需要深入分析",
            "confidence": 0.4,
            "reasoning": "問題較為獨特，需採用系統性分析方法"
        }
    
    def _deep_analysis(self, problem: ProblemContext, previous_steps: List[AnalysisStep]) -> Dict[str, Any]:
        """深度分析"""
        # 5Why分析
        whys = self._generate_5whys(problem)
        
        # 魚骨圖分析
        fishbone = self._fishbone_analysis(problem)
        
        # 整合分析結果
        combined_insight = f"深度分析顯示：{whys[-1]}，主要影響因素包括：{', '.join(fishbone['categories'])}"
        
        return {
            "insight": combined_insight,
            "confidence": 0.8,
            "reasoning": "通過5Why和魚骨圖分析獲得深度洞察"
        }
    
    def _systemic_thinking(self, problem: ProblemContext, previous_steps: List[AnalysisStep]) -> Dict[str, Any]:
        """系統性思考"""
        # 考慮系統間相互作用
        systemic_factors = []
        
        # 環境因素分析
        if problem.environment:
            for key, value in problem.environment.items():
                if "load" in key.lower() and isinstance(value, (int, float)) and value > 80:
                    systemic_factors.append(f"高{key}可能是觸發因素")
        
        # 時間因素
        if "time" in problem.description.lower() or "when" in str(problem.environment).lower():
            systemic_factors.append("時間因素可能是關鍵變量")
        
        final_insight = f"系統性分析表明：{'; '.join(systemic_factors)}"
        
        return {
            "insight": final_insight,
            "confidence": 0.85,
            "reasoning": "從系統整體角度考慮相互作用因素"
        }
    
    def _generate_5whys(self, problem: ProblemContext) -> List[str]:
        """生成5Why分析鏈"""
        whys = []
        current_level = problem.description
        
        for i in range(5):
            why = self._generate_why(current_level, i)
            whys.append(why)
            current_level = why
        
        return whys
    
    def _generate_why(self, level: str, depth: int) -> str:
        """生成單個Why答案"""
        why_templates = [
            f"因為{level}導致系統異常",
            f"由於{level}引發的連鎖反應",
            f"{level}的根本原因是配置錯誤",
            f"{level}反映了設計缺陷",
            f"{level}指向流程管理問題"
        ]
        
        return why_templates[depth % len(why_templates)]
    
    def _fishbone_analysis(self, problem: ProblemContext) -> Dict[str, Any]:
        """魚骨圖分析"""
        categories = ["人員", "流程", "技術", "環境"]
        
        factors = {}
        for category in categories:
            factors[category] = self._identify_factors_for_category(problem, category)
        
        return {
            "categories": categories,
            "factors": factors,
            "primary_factors": [cat for cat, facts in factors.items() if len(facts) > 2]
        }
    
    def _identify_factors_for_category(self, problem: ProblemContext, category: str) -> List[str]:
        """識別特定類別的因素"""
        factors = []
        
        if category == "技術":
            if any(keyword in str(problem.environment).lower() 
                   for keyword in ["server", "database", "api", "network"]):
                factors.extend(["技術架構", "系統配置", "網絡延遲"])
        
        elif category == "流程":
            if any(keyword in problem.description.lower() 
                   for keyword in ["process", "workflow", "procedure"]):
                factors.extend(["流程設計", "標準操作", "監控機制"])
        
        return factors

class RootCauseAnalyzer:
    """根因分析Agent"""
    
    def __init__(self):
        self.knowledge_base = KnowledgeBase()
        self.thinking_engine = DeepThinkingEngine(self.knowledge_base)
    
    def analyze(self, problem: ProblemContext) -> RootCauseReport:
        """執行完整根因分析"""
        start_time = time.time()
        
        # 執行深度思考分析
        analysis_steps = self.thinking_engine.analyze(problem)
        
        # 生成根本原因
        root_causes = self._generate_root_causes(analysis_steps)
        
        # 生成建議
        recommendations = self._generate_recommendations(root_causes)
        
        # 計算總置信度
        total_confidence = sum(rc.confidence for rc in root_causes) / len(root_causes) if root_causes else 0
        
        return RootCauseReport(
            problem=problem,
            root_causes=root_causes,
            analysis_steps=analysis_steps,
            recommendations=recommendations,
            total_confidence=total_confidence,
            analysis_duration=time.time() - start_time
        )
    
    def _generate_root_causes(self, steps: List[AnalysisStep]) -> List[RootCause]:
        """從分析步驟生成根本原因"""
        causes = []
        
        # 提取高置信度洞察
        high_confidence_steps = [s for s in steps if s.confidence > 0.7]
        
        for step in high_confidence_steps:
            cause = self._extract_cause_from_insight(step.insight)
            causes.append(RootCause(
                cause=cause,
                confidence=step.confidence,
                evidence=[step.reasoning],
                impact_level="high" if step.confidence > 0.8 else "medium",
                category=step.step_name
            ))
        
        return causes
    
    def _extract_cause_from_insight(self, insight: str) -> str:
        """從洞察中提取根本原因"""
        # 簡化的根本原因提取
        if "因為" in insight:
            return insight.split("因為")[-1].strip()
        elif "可能是" in insight:
            return insight.split("可能是")[-1].strip()
        else:
            return insight
    
    def _generate_recommendations(self, root_causes: List[RootCause]) -> List[str]:
        """基於根本原因生成建議"""
        recommendations = []
        
        for cause in root_causes:
            if "配置" in cause.cause:
                recommendations.append("立即審查和更新相關配置")
            elif "流程" in cause.cause:
                recommendations.append("優化業務流程並建立監控機制")
            elif "技術" in cause.cause:
                recommendations.append("進行技術架構評估和優化")
            else:
                recommendations.append(f"針對{cause.cause}制定改進計劃")
        
        return recommendations

# CLI界面
@click.group()
def cli():
    """思考根因分析Agent CLI"""
    pass

@cli.command()
@click.option('--file', '-f', help='問題描述JSON文件')
@click.option('--interactive', '-i', is_flag=True, help='交互式輸入')
def analyze(file, interactive):
    """執行根因分析"""
    
    analyzer = RootCauseAnalyzer()
    
    if interactive:
        console.print("[bold blue]思考根因分析Agent[/bold blue]")
        console.print("請描述您要分析的問題：")
        
        title = click.prompt("問題標題")
        description = click.prompt("詳細描述")
        symptoms = click.prompt("症狀（用逗號分隔）").split(",")
        
        problem = ProblemContext(
            title=title,
            description=description,
            symptoms=[s.strip() for s in symptoms]
        )
    
    elif file:
        with open(file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            problem = ProblemContext(**data)
    
    else:
        console.print("[red]請提供問題描述文件或使用交互式模式[/red]")
        return
    
    # 執行分析
    with Progress() as progress:
        task = progress.add_task("[cyan]深度思考分析中...", total=100)
        
        for i in range(5):
            time.sleep(0.5)
            progress.update(task, advance=20)
        
        report = analyzer.analyze(problem)
    
    # 顯示結果
    console.print("\n[bold green]=== 根因分析報告 ===[/bold green]")
    console.print(f"問題: {report.problem.title}")
    console.print(f"分析耗時: {report.analysis_duration:.2f}秒")
    console.print(f"總體置信度: {report.total_confidence:.2%}")
    
    # 根本原因
    table = Table(title="根本原因")
    table.add_column("原因", style="cyan")
    table.add_column("置信度", style="magenta")
    table.add_column("影響級別", style="yellow")
    
    for cause in report.root_causes:
        table.add_row(
            cause.cause,
            f"{cause.confidence:.2%}",
            cause.impact_level
        )
    
    console.print(table)
    
    # 建議
    console.print("\n[bold blue]改進建議:[/bold blue]")
    for i, rec in enumerate(report.recommendations, 1):
        console.print(f"{i}. {rec}")

@cli.command()
def demo():
    """運行演示案例"""
    
    analyzer = RootCauseAnalyzer()
    
    # 演示案例
    demo_problems = [
        ProblemContext(
            title="網站訪問緩慢",
            description="用戶反映網站加載時間超過10秒",
            symptoms=["頁面加載慢", "超時錯誤", "用戶投訴增加"],
            environment={"peak_hours": True, "server_load": "90%", "recent_changes": "數據庫更新"}
        ),
        ProblemContext(
            title="客戶流失增加",
            description="本月客戶流失率從5%上升到12%",
            symptoms=["取消訂閱增加", "負面評價", "競品用戶增長"],
            environment={"new_feature": "界面改版", "competitor_promotion": "降價20%"}
        )
    ]
    
    console.print("[bold green]=== 演示案例分析 ===[/bold green]")
    
    for problem in demo_problems:
        console.print(f"\n[bold]分析問題: {problem.title}[/bold]")
        report = analyzer.analyze(problem)
        
        console.print(f"根本原因: {report.root_causes[0].cause if report.root_causes else '分析中'}")
        console.print(f"置信度: {report.total_confidence:.2%}")

if __name__ == "__main__":
    cli()