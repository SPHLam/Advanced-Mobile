import 'package:jarvis/views/Bot/model/bot.dart';

final List<Bot> bots = [
  const Bot(
    name: "GPT-4o mini",
    prompt:
    "You are a lightweight, efficient conversational AI developed by OpenAI. You provide quick, accurate responses for everyday tasks and casual conversations.",
    team: "OpenAI",
    imageUrl: "assets/logo/gpt-4o-mini.png",
    isPublish: true,
    listKnowledge: ["General knowledge", "Quick responses", "Task assistance"],
  ),
  const Bot(
    name: "GPT-4o",
    prompt:
    "You are an advanced conversational AI created by OpenAI. You excel at complex tasks, creative writing, and detailed problem-solving with a friendly tone.",
    team: "OpenAI",
    imageUrl: "assets/logo/gpt-4o.png",
    isPublish: true,
    listKnowledge: ["Creative writing", "Complex reasoning", "Multitasking"],
  ),
  const Bot(
    name: "Gemini 1.5 Flash",
    prompt:
    "You are a fast and versatile AI model from Google DeepMind, designed for rapid responses and seamless integration with Google services.",
    team: "Google DeepMind",
    imageUrl: "assets/logo/gemini-1.5-flash.png",
    isPublish: true,
    listKnowledge: ["Fast processing", "Google integration", "Web assistance"],
  ),
  const Bot(
    name: "Gemini 1.5 Pro",
    prompt:
    "You are a professional-grade AI from Google DeepMind, built for in-depth analysis, multimodal reasoning, and high-performance tasks.",
    team: "Google DeepMind",
    imageUrl: "assets/logo/gemini-1.5-pro.png",
    isPublish: true,
    listKnowledge: ["Multimodal reasoning", "Data analysis", "Advanced tasks"],
  ),
  const Bot(
    name: "Claude 3 Haiku",
    prompt:
    "You are a concise and thoughtful AI created by Anthropic. Inspired by poetry, you deliver clear, ethical, and succinct answers.",
    team: "Anthropic Team",
    imageUrl: "assets/logo/claude-3-haiku.png",
    isPublish: true,
    listKnowledge: ["Ethics", "Concise responses", "Critical thinking"],
  ),
  const Bot(
    name: "Claude 3 Sonnet",
    prompt:
    "You are an intelligent and balanced AI from Anthropic, designed for deep reasoning, nuanced writing, and ethical decision-making.",
    team: "Anthropic Team",
    imageUrl: "assets/logo/claude-3-sonnet.png",
    isPublish: true,
    listKnowledge: ["Deep reasoning", "Ethical considerations", "Writing"],
  ),
  const Bot(
    name: "Deepseek Chat",
    prompt:
    "You are a research-oriented AI designed by the Deepseek Team to assist with complex topics, data insights, and precise content generation.",
    team: "Deepseek Team",
    imageUrl: "assets/logo/deepseek.png",
    isPublish: true,
    listKnowledge: ["Research", "Data analysis", "Precision content"],
  ),
];