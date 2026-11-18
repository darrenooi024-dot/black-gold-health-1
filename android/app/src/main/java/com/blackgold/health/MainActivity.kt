package com.blackgold.health

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Gold = Color(0xFFD6B15E)
private val Black = Color(0xFF090909)
private val Panel = Color(0xFF191919)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { BlackGoldApp() }
    }
}

@Composable
fun BlackGoldApp() {
    val context = LocalContext.current
    val prefs = remember { context.getSharedPreferences("black_gold_health", android.content.Context.MODE_PRIVATE) }
    var selected by remember { mutableStateOf("总览") }
    var profile by remember { mutableStateOf("我") }
    var weightInput by remember(profile) {
        mutableStateOf(prefs.getString("weight_$profile", "") ?: "")
    }
    var savedWeight by remember(profile) {
        mutableStateOf(prefs.getString("weight_$profile", "") ?: "")
    }
    var message by remember(profile) { mutableStateOf("") }

    MaterialTheme(colorScheme = darkColorScheme(primary = Gold, background = Black, surface = Panel)) {
        Scaffold(
            containerColor = Black,
            bottomBar = {
                NavigationBar(containerColor = Panel, contentColor = Gold) {
                    listOf("总览", "体重", "饮食", "运动", "我的").forEach { item ->
                        NavigationBarItem(
                            selected = selected == item,
                            onClick = { selected = item },
                            icon = {
                                Text(
                                    when (item) { "总览" -> "⌂"; "体重" -> "↗"; "饮食" -> "◉"; "运动" -> "✦"; else -> "●" },
                                    fontSize = 20.sp
                                )
                            },
                            label = { Text(item, fontSize = 11.sp) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Gold,
                                selectedTextColor = Gold,
                                indicatorColor = Color(0xFF342B18),
                                unselectedIconColor = Color.LightGray,
                                unselectedTextColor = Color.LightGray
                            )
                        )
                    }
                }
            }
        ) { pad ->
            LazyColumn(
                modifier = Modifier.fillMaxSize().background(Black).padding(pad).padding(horizontal = 18.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                item {
                    Spacer(Modifier.height(14.dp))
                    Text("BLACK GOLD", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.Bold, letterSpacing = 3.sp)
                    Text("私人 AI 健康教练", color = Color.White, fontSize = 26.sp, fontWeight = FontWeight.Bold)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.padding(top = 12.dp)) {
                        listOf("我", "宝宝").forEach { person ->
                            FilterChip(
                                selected = profile == person,
                                onClick = { profile = person },
                                label = { Text(person) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = Gold,
                                    selectedLabelColor = Black,
                                    labelColor = Color.White
                                )
                            )
                        }
                    }
                }

                when (selected) {
                    "总览" -> {
                        item { CardBlock("今日概况", "先记录今天的身体状态", "体重、饮食、饮水和活动都会显示在这里") }
                        item { Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) { Metric("最近体重", if (savedWeight.isBlank()) "-- kg" else "$savedWeight kg"); Metric("饮水", "0 ml") } }
                        item { Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) { Metric("饮食", "0 kcal"); Metric("步数", "0") } }
                        item { CardBlock("快速记录", "体重 · 饮食 · 饮水 · 睡眠", "点击下方「体重」即可输入并保存体重。") }
                        item { CardBlock("AI 教练", "严格监督 · 专业分析 · 主动指导", "AI 云端服务尚未连接；当前版本先提供基础本地记录。") }
                    }
                    "体重" -> {
                        item {
                            Card(
                                colors = CardDefaults.cardColors(containerColor = Panel),
                                shape = RoundedCornerShape(18.dp),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Column(
                                    Modifier.padding(18.dp),
                                    verticalArrangement = Arrangement.spacedBy(14.dp)
                                ) {
                                    Text("体重记录", color = Gold, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                                    Text(if (savedWeight.isBlank()) "还没有体重记录" else "最近记录：$savedWeight kg", color = Color.White, fontSize = 21.sp, fontWeight = FontWeight.Bold)
                                    OutlinedTextField(
                                        value = weightInput,
                                        onValueChange = { value ->
                                            if (value.matches(Regex("^\\d{0,3}(\\.\\d{0,2})?$"))) {
                                                weightInput = value
                                                message = ""
                                            }
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        label = { Text("输入体重（kg）") },
                                        placeholder = { Text("例如：65.5") },
                                        singleLine = true,
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedTextColor = Color.White,
                                            unfocusedTextColor = Color.White,
                                            focusedBorderColor = Gold,
                                            unfocusedBorderColor = Color.Gray,
                                            focusedLabelColor = Gold,
                                            cursorColor = Gold
                                        )
                                    )
                                    Button(
                                        onClick = {
                                            val value = weightInput.toDoubleOrNull()
                                            if (value == null || value !in 20.0..500.0) {
                                                message = "请输入 20 至 500 kg 之间的有效体重。"
                                            } else {
                                                val normalized = String.format(java.util.Locale.US, "%.1f", value)
                                                prefs.edit().putString("weight_$profile", normalized).apply()
                                                savedWeight = normalized
                                                weightInput = normalized
                                                message = "已保存到「$profile」的手机本地记录。"
                                            }
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        colors = ButtonDefaults.buttonColors(containerColor = Gold, contentColor = Black)
                                    ) {
                                        Text("保存体重", fontWeight = FontWeight.Bold)
                                    }
                                    if (message.isNotBlank()) {
                                        Text(message, color = if (message.startsWith("已保存")) Gold else Color(0xFFFF8A80), fontSize = 13.sp)
                                    }
                                    Text("目前保存在这台手机内，并按「我 / 宝宝」分别记录；尚未同步到云端。", color = Color.LightGray, fontSize = 12.sp, lineHeight = 18.sp)
                                }
                            }
                        }
                    }
                    "饮食" -> item { CardBlock("饮食记录", "饮食功能尚在开发", "目前此页面还不能记录食物或计算热量。") }
                    "运动" -> item { CardBlock("运动记录", "运动功能尚在开发", "步行、跑步、游泳等项目的记录功能还未接入。") }
                    else -> item { CardBlock("我的", "个人资料", "当前记录分为「我」和「宝宝」两个本地档案。云端账号与共享功能尚未接入。") }
                }
                item {
                    Text(
                        "版本 1.0.1 · 体重本地记录测试版",
                        color = Color.Gray,
                        fontSize = 11.sp,
                        modifier = Modifier.padding(vertical = 12.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun CardBlock(title: String, headline: String, detail: String) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Panel),
        shape = RoundedCornerShape(18.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(title, color = Gold, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            Text(headline, color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.Bold)
            Text(detail, color = Color.LightGray, fontSize = 13.sp, lineHeight = 19.sp)
        }
    }
}

@Composable
fun RowScope.Metric(label: String, value: String) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Panel),
        shape = RoundedCornerShape(16.dp),
        modifier = Modifier.weight(1f)
    ) {
        Column(Modifier.padding(15.dp)) {
            Text(label, color = Color.LightGray, fontSize = 12.sp)
            Spacer(Modifier.height(7.dp))
            Text(value, color = Gold, fontSize = 22.sp, fontWeight = FontWeight.Bold)
        }
    }
}
