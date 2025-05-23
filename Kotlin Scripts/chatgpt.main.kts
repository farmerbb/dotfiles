#!/usr/bin/env kotlin

@file:DependsOn("com.github.ajalt.clikt:clikt-jvm:3.0.1")
@file:DependsOn("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
@file:DependsOn("com.squareup.okhttp3:okhttp:4.10.0")
@file:DependsOn("com.squareup.retrofit2:retrofit:2.9.0")
@file:DependsOn("com.squareup.retrofit2:converter-gson:2.9.0")

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.output.TermUi.echo
import com.google.gson.annotations.SerializedName
import kotlinx.coroutines.runBlocking
import java.util.concurrent.TimeUnit
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.awaitResponse
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST

private val apiKey = "[REDACTED]"

private val openAiApi = Retrofit.Builder()
    .baseUrl("https://api.openai.com/v1/")
    .addConverterFactory(GsonConverterFactory.create())
    .client(okHttpClient())
    .build()
    .create(OpenAIAPI::class.java)

fun okHttpClient(): OkHttpClient {
    return OkHttpClient.Builder().apply {
        addInterceptor(HeaderInterceptor())
        writeTimeout(60, TimeUnit.SECONDS)
        readTimeout(60, TimeUnit.SECONDS)
    }.build()
}

interface OpenAIAPI {
    @POST("chat/completions")
    fun chatCompletions(@Body chatRequest: ChatRequest): Call<ChatResponse>
}

data class ChatRequest (
    val model: String,
    val messages: List<Message>
)

data class Message (
    val role: String,
    val content: String
)

data class ChatResponse (
    val id: String,

    @SerializedName("object")
    val chatResponseObject: String,

    val created: Long,
    val model: String,
    val usage: Usage,
    val choices: List<Choice>
)

data class Choice (
    val message: Message,

    @SerializedName("finish_reason")
    val finishReason: String,

    val index: Long
)

data class Usage (
    @SerializedName("prompt_tokens")
    val promptTokens: Long,

    @SerializedName("completion_tokens")
    val completionTokens: Long,

    @SerializedName("total_tokens")
    val totalTokens: Long
)

class HeaderInterceptor: Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response =
        chain.request()
            .newBuilder()
            .addHeader("Authorization", "Bearer $apiKey")
            .build()
            .let(chain::proceed)
}

class ChatGPT : CliktCommand() {
    override fun run() = runBlocking {
        while(true) {
            prompt("You")?.let {
                callApi(it)
            }
        }
    }
}

suspend fun callApi(message: String) {
    val response = openAiApi.chatCompletions(
        chatRequest = ChatRequest(
            model = "gpt-3.5-turbo",
            messages = listOf(
                Message(
                    role = "user",
                    content = message
                )
            ),
        )
    ).awaitResponse()

    if (response.isSuccessful) {
        response.body()?.choices?.firstOrNull()?.message?.content?.let(::echo)
    } else {
        echo(response.errorBody()?.string())
    }

    echo("")
}

ChatGPT().main(args)
